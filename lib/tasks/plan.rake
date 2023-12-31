desc "Upgrade subscription plan"
task :upgrade_subscription_plan => :environment do
  ## Before upgrade:
  ## - Create a product on Stripe
  ## - Change value to create new subscription plan, stripe_plan_id is the most IMPORTANT

  ActiveRecord::Base.transaction do
    # Create new subscription plan in backend
    old_plan = Plan.find_by(amount: 99, interval: "month", name: "$0.99/month", currency: "usd", interval_count: 1)
    new_plan = Plan.find_by(amount: 89, interval: "month", name: "$0.89/month", currency: "usd", interval_count: 1)
    unless new_plan.present?
      new_plan = Plan.create(amount: 89, interval: "month", name: "$0.89/month", currency: "usd", interval_count: 1)
    end
    # Submit new plan to Stripe
    new_plan.submit("prod_KjR2BrkCR6M4SP") # product is from created product from Stripe

    # Convert all shops current credit from token credit into dollar credit
    Shop.find_each{|shop| shop.update(credit: shop.credit * shop.current_subscription.plan.amount.to_f / 100) if shop.current_subscription.present?}

    # Update all shop to new subscription plan
    Subscription.find_each do |s|
      new_quantity = s.quantity * old_plan.amount / new_plan.amount
      s.change_plan(new_plan.reload.stripe_plan_id, new_quantity)
      s.update(plan_id: new_plan.id, quantity: new_quantity)
    end
  end
end

desc "Check if all shop moved to new subscription plan"
task :check_if_subscription_plan_all_changed => :environment do
  ActiveRecord::Base.transaction do
    a = []
    new_plan = Plan.find_by(amount: 89, interval: "month", name: "$0.89/month", currency: "usd", interval_count: 1)
    Shop.find_each do |shop|
      shop_subscription = shop.current_subscription
      shop_stripe_subscription = Stripe::Subscription.retrieve(shop_subscription.stripe_id) rescue nil
      # shop_subscription.change_plan(new_plan.reload.stripe_plan_id) if shop_subscription.present? && shop_subscription.plan.id != new_plan.id
      a.push(shop.id) if (shop_subscription && shop_subscription.plan.id != new_plan.id) || (shop_stripe_subscription && (shop_stripe_subscription.plan.nil? || shop_stripe_subscription.plan.amount != 89))
    end
    puts a
  end
end
