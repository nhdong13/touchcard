module SubscriptionsHelper

  QUANTITIES = [50, 100, 150, 200, 250, 300, 400, 500, 750, 1000, 1500, 2000, 3000, 4000, 5000, 7500, 10000]


  def select_options
    QUANTITIES.collect { |q| [q.to_s, q] }
  end

  def checkout_quantity(current_shop)
    QUANTITIES[checkout_index(current_shop)] || QUANTITIES[0]
  end

  def checkout_index(current_shop)
    monthly_customers = current_shop.last_month || 0
    QUANTITIES.rindex{ |x| x < monthly_customers } || 0
  end

  def update_quantity(current_shop)
    QUANTITIES[update_index(current_shop)] || QUANTITIES[0]
  end

  def update_index(current_shop)
    monthly_subscription = current_shop.current_subscription.quantity || 0
    QUANTITIES.index{ |x| x >= monthly_subscription } || 0
  end

  def slider_max
    QUANTITIES.count - 1
  end

end


