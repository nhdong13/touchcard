desc "Upgrade subscription plan"
  task :upgrade_subsciption_plan => :environment do
    ## Before upgrade:
    ## - Create a product on Stripe
    ## - Change value to create new subscription plan, stripe_plan_id is the most IMPORTANT

    ActiveRecord::Base.transaction do
      # Create new subscription plan in backend
      new_plan = Plan.create(amount: 89, interval: "month", name: "$0.89/month", currency: "usd", interval_count: 1)
      # Submit new plan to Stripe
      new_plan.submit("prod_Jj0tDTs8fAdyrq") # product is from created product from Stripe

      # Update all shop to new subscription plan
      Shop.all.each do |shop|
        shop_subscription = shop.current_subscription
        if shop_subscription.present?
          old_quantity = shop_subscription.quantity
          old_coupon = shop_subscription.coupon
          shop_subscription.destroy
          Subscription.create(shop_id: shop.id, plan_id: new_plan.id, quantity: old_quantity, coupon: old_coupon)
        end
      end
    end
end
