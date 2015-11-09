class BulkTemplate < CardTemplate

  def bulk_send
    shop = self.shop
    shop.new_sess

    begin
      customer_count = ShopifyAPI::Customer.count(created_at_min: self.customers_after, created_at_max: self.customers_before)
    rescue # Shopify API limit
      wait(2)
      customer_count = ShopifyAPI::Customer.count(created_at_min: self.customers_after, created_at_max: self.customers_before)
    end

    pages = (customer_count/250.0).ceil

    1.upto(pages) do |page|
      # Get 250 customers
      customers = ShopifyAPI::Customer.where(created_at_min: self.customers_after, created_at_max: self.customers_before, limit: 250, page: page)

      # Loop through and create a card for each
      customer.each do |customer|
        Postcard.create_postcard(self.id, customer, nil)
      end
    end
  end
end
