class GeneratePostcardJob < ActiveJob::Base
	queue_as :default

	def perform shop, campaign
    shop.new_sess

    campaign.processing!
    campaign.save!

    customers_before = campaign.campaign_type == CardOrder.automation ? Time.new.strftime("%FT%T%:z") : campaign.created_at

    customers = ShopifyAPI::Customer.where(
      created_at_max: customers_before,
      limit: 250,
    )

    while true
      customers.each do |customer|
        postcard = Postcard.new
        postcard.card_order = campaign
        postcard.customer = Customer.from_shopify!(customer)

        postcard.save!
      end

      break unless customers.next_page?
      customers = customers.fetch_next_page
    end
	end
end