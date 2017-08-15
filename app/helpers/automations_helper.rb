module AutomationsHelper
  def type_options
    {
      "Post Sale Order" => "PostSaleOrder",
      "Customer Winback" => "CustomerWinbackOrder",
      "Abandoned Card" => "AbandonedCard",
      "Lifetime Purchase" => "LifetimePurchaseOrder"
    }
  end
end
