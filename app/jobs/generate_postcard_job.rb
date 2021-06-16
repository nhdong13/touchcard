class GeneratePostcardJob < ActiveJob::Base
	queue_as :default

	def perform shop, campaign
		shop.new_sess

		campaign.campaign_status = CardOrder.processing
		campaign.save!

		customers_before = campaign.campaign_type == CardOrder.automation ? Time.new.strftime("%FT%T%:z") : campaign.created_at

	    begin
	      customer_count = ShopifyAPI::Customer.count(
	        created_at_max: customers_before
	      )
	    rescue # Shopify API limit
	      sleep(2)
	      retry
	    end

	    pages = (customer_count / 250.0).ceil

	    1.upto(pages) do |page|
	      # Get 250 customers
	      customers = ShopifyAPI::Customer.where(
	        created_at_max: customers_before,
	        limit: 250,
	        page: page
	      )
	      # TODO fix this
	      # Loop through and create a card for each
	      customer.each do |customer|
	        postcard = Postcard.new
	        postcard.card_order = campaign
	        postcard.customer = customer
	        
	        postcard.save!
	      end
	    end
	end
end