module AutomationsHelper
  def type_options
    {
      "Post Sale Order" => "PostSaleOrder",
      "Customer Winback" => "CustomerWinbackOrder",
      "Abandoned Checkout" => "AbandonedCheckout",
      "Lifetime Purchase" => "LifetimePurchaseOrder"
    }
  end

  def has_active_discount(card_order)
    card_order&.front_json['discount_x'] && card_order&.front_json['discount_y']
  end

end
