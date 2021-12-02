desc "Upgrade subscription plan"
  task :upgrade_subsciption_plan => :environment do
    ## Before upgrade:
    ## - Create a product on Stripe
    ## - Change value to create new subscription plan, stripe_plan_id is the most IMPORTANT

    ActiveRecord::Base.transaction do
      # Create new subscription plan in backend
      new_plan = Plan.find_by(amount: 89, interval: "month", name: "$0.89/month", currency: "usd", interval_count: 1)
      unless new_plan.present?
        new_plan = Plan.create(amount: 89, interval: "month", name: "$0.89/month", currency: "usd", interval_count: 1)
      end
      # Submit new plan to Stripe
      new_plan.submit("prod_Jj0tDTs8fAdyrq") # product is from created product from Stripe

      # Convert all shops current credit from token credit into dollar credit
      Shop.find_each{|shop| shop.update(credit: shop.credit * shop.current_subscription.plan.amount.to_f / 100) if shop.current_subscription.present?}

      # Update all shop to new subscription plan
      Shop.find_each do |shop|
        shop_subscription = shop.current_subscription
        shop_subscription.change_plan(new_plan.reload.stripe_plan_id) if shop_subscription.present?
      end

      Subscription.update_all(plan_id: new_plan.id)
        # Init subscription dollar value into Subscription table and set current current value for each
      Subscription.find_each{|sub| sub.update(value: sub.quantity * sub.plan.amount.to_f / 100)}
    end
end

desc "Check if all shop moved to new subscription plan"
  task :check_if_subscription_plan_all_changed => :environment do
    ActiveRecord::Base.transaction do
      new_plan = Plan.find_by(amount: 89, interval: "month", name: "$0.89/month", currency: "usd", interval_count: 1)
      Shop.find_each do |shop|
        shop_subscription = shop.current_subscription
        shop_subscription.change_plan(new_plan.reload.stripe_plan_id) if shop_subscription.present? && shop_subscription.plan.id != new_plan.id
      end
    end
end
