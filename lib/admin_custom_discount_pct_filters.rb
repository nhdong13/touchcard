# This module just for the custom discount pct filter in 2 admin pages: campaigns and postcards
# Because card_orders table and postcards table have same column discount_pct

module AdminCustomDiscountPctFilters
  
  # Somehow when use custom filter numeric, input 1 become true and cannot filter with 0
  def negative_value(value)
    value = 1 if value.to_s == "true"
    value = -(value.to_i.abs)
    value
  end
  
  def has_discount
    self.where("(front_json ->> 'discount_x' IS NOT NULL AND front_json ->> 'discount_y' IS NOT NULL)")
    .or(self.where("(back_json ->> 'discount_x' IS NOT NULL AND back_json ->> 'discount_y' IS NOT NULL)"))
  end

  def campaigns_or_postcards
    self.to_s == "CardOrder" ? has_discount : self
  end

  def discount_pct_is_equals(value)
    campaigns_or_postcards.where(discount_pct: negative_value(value))
  end

  def discount_pct_is_greater_than(value)
    campaigns_or_postcards.where("discount_pct < ?", negative_value(value))
  end

  def discount_pct_is_less_than(value)
    campaigns_or_postcards.where("discount_pct > ?", negative_value(value))
  end
end