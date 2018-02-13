module SubscriptionsHelper

  QUANTITIES = [50, 100, 150, 200, 250, 300, 400, 500, 750, 1000, 1500, 2000, 3000]

  def select_options
    QUANTITIES.collect { |q| [q.to_s, q] }
  end

  def selected_value(current_shop)
    monthly_customers = current_shop.last_month || 0
    QUANTITIES.reverse.find{ |x| x < monthly_customers } || QUANTITIES[0]
  end

  def slider_index(current_shop)
    monthly_customers = current_shop.last_month || 0
    QUANTITIES.rindex{ |x| x < monthly_customers } || 0
  end

  def slider_max
    QUANTITIES.count - 1
  end


end


