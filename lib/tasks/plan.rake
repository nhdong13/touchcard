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
        shop_subscription.change_plan(new_plan.reload.stripe_plan_id) if shop_subscription.present?
      end
    end
end
