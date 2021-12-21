# This module just for the custom discount pct filter in 2 admin pages: campaigns and postcards
# Because card_orders table and postcards table have same column discount_pct

module AdminCustomDiscountPctFilters

  def negative_value(value)
    value = -(value.to_i.abs)
    value
  end

  def discount_pct_is_equals(value)
    where("discount_pct = ?", negative_value(value))
  end

  def discount_pct_is_greater_than(value)
    where("discount_pct < ?", negative_value(value))
  end

  def discount_pct_is_less_than(value)
    where("discount_pct > ?", negative_value(value))
  end
end