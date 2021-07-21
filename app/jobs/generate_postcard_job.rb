class GeneratePostcardJob < ActiveJob::Base
	queue_as :default

  before_enqueue do |job|
    # job.arguments[1] => card order instance
    throw :abort if (job.arguments[1].archived || job.arguments[1].complete?)
  end

  after_perform do |job|
    # job.arguments[0] => shop instance
    # job.arguments[1] => card order instance
    SchedulingPostcardJob.set(wait: 1.minutes).perform_later(job.arguments[0], job.arguments[1]) unless job.arguments[1].archived
  end

	def perform shop, campaign
    return unless (campaign.enabled? && campaign.processing?  && !campaign.archived)
    shop.new_sess

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
    existing_customers = campaign.postcards
    while true
      customers.each do |c|
        customer = Customer.from_shopify!(c)
        # If customer don't pass filter then skip
        next unless (customer_targeting_service.customer_pass_filter?(customer.id) &&
                    !(customer.international? ^ campaign.international) &&
                    !existing_customers.exists?(customer_id: customer.id)
                    )
        postcard = Postcard.new
        postcard.customer = customer
        postcard.send_date = Time.now

        campaign.postcards << postcard

        postcard.save!
      end

      break unless customers.next_page?
      customers = customers.fetch_next_page
    end
	end
end