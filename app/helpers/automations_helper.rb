module AutomationsHelper
  def type_options
    {
      "Post Sale Order" => "PostSaleOrder",
      "Customer Winback" => "CustomerWinbackOrder",
      "Abandoned Checkout" => "AbandonedCheckout",
      "Lifetime Purchase" => "LifetimePurchaseOrder"
    }
  end
end
