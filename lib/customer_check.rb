module CustomerCheck

  def get_customer_number(shop_id, start_date, end_date)
    shop = Shop.find(shop_id)
    shop.new_sess
    return ShopifyAPI::Customer.count(:created_at_min => start_date, :created_at_max => end_date)
  end

end
