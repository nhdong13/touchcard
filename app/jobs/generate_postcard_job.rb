class GeneratePostcardJob < ActiveJob::Base
	queue_as :default

	def perform shop, campaign
    shop.new_sess

    campaign.processing!
    campaign.save!

    # Get customer from shopify
    customers_before = campaign.automation? ? Time.new.strftime("%FT%T%:z") : campaign.created_at
    customers = ShopifyAPI::Customer.where(
      created_at_max: customers_before,
      limit: 250,
    )

    # Set customer filter
    filter = campaign.filters.last
    customer_targeting_service =  CustomerTargetingService.new({shop: shop}, filter.filter_data[:accepted], filter.filter_data[:removed])

    # Get already exisiting customer in postcard list => 1 customer only sent 1 postcard
    # This is for use case when we go from paused status to processing
    existing_customers = Postcard.joins(:card_order).where(card_order_id: campaign.id)

    while true
      customers.each do |c|
        customer = Customer.from_shopify!(c)
        # If customer don't pass filter then skip
        next unless customer_targeting_service.customer_pass_filter? customer.id ||
                    !(customer.international? ^ campaign.international) ||
                    !existing_customers.exists?(customer_id: customer.id)

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