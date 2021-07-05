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

    filter = campaign.filters.last
    customer_targeting_service =  CustomerTargetingService.new({shop: shop}, filter.filter_data[:accepted], filter.filter_data[:removed])
    while true
      customers.each do |c|
        customer = Customer.from_shopify!(c)
        # If customer don't pass filter then skip
        next unless customer_targeting_service.customer_pass_filter? customer.id

        postcard = Postcard.new
        # postcard.card_order = campaign
        postcard.customer = customer
        postcard.postcard_trigger = campaign
        postcard.send_date = campaign.send_delay.blank? ? campaign.send_date_start : campaign.send_date_start + campaign.send_delay.weeks

        campaign.postcards << postcard

        postcard.save!
      end

      break unless customers.next_page?
      customers = customers.fetch_next_page
    end
	end
end