module SubscriptionsHelper

  QUANTITIES = [10, 20, 30, 40, 50, 60, 70, 80, 90,
                100, 125, 150, 175, 200, 250, 300, 350, 400, 450,
                500, 600, 700, 800, 900,
                1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 
                5000, 6000, 7000, 8000, 9000, 10000]


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


