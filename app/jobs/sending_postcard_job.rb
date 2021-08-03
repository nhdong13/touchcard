=begin
  This new logic of sending postcard is status-centric instead of process-centric like before

  Status is now play as flag/signal for corresponding process to run. Before that, it's just merely
  report which process has been done

  For example, Process fetch history data and fetch customer data can only be run when
  the campaign in processing status
=end
class SendingPostcardJob < ActiveJob::Base
  queue_as :default

  before_enqueue do |job|
    # job.arguments[1] => card order instance
    throw :abort if (job.arguments[1].archived || job.arguments[1].complete?)
  end

  # after_perform do |job|
  #   # job.arguments[0] => shop instance
  #   # job.arguments[1] => card order instance
  #   byebug
  #   if ((job.arguments[1].scheduled? && Time.now.end_of_day < job.arguments[1].send_date_start) ||
  #     (job.arguments[1].sending? && !reach_end_date(job.arguments[1])))
  #     SendingPostcardJob.set(wait: 1.day).perform_later(job.arguments[0], job.arguments[1])
  #   else
  #     SendingPostcardJob.set(wait: 2.minutes).perform_later(job.arguments[0], job.arguments[1])
  #   end
  # end

  def perform shop, campaign, reset_status_to_processing_in_new_loop = false
    reset_status_to_processing_in_new_loop = false
    wait_time = 2.minutes
    campaign.processing! if reset_status_to_processing_in_new_loop
    if campaign.enabled?
      case campaign.campaign_status
      when "processing"
        Rails.logger.debug ">>>>>>>>>>>>>>>>>>>>>> [NOTE] Processing"
        shop.new_sess

        # =================================================
        # Fetching Order data from shopify
        # =================================================
        params = {status: "any",
                  limit: 250
                  }
        shopify_orders = ShopifyAPI::Order.all(params: params)
        while true
          shopify_orders.each do |shopify_order|
            begin
              result = Order.from_shopify!(shopify_order, shop)
              order = result[:order]
              is_order_exists = result[:is_order_exists]
            rescue ActiveRecord::RecordInvalid
              next Rails.logger.debug "unable to create order (duplicate webhook?)"
            end
            next if is_order_exists

            order.connect_to_postcard
            next Rails.logger.debug "no customer" unless order.customer
            next Rails.logger.debug "no default address" unless shopify_order.customer.respond_to?(:default_address)
            next Rails.logger.debug "no default address" unless shopify_order.customer.default_address
            next Rails.logger.debug "no street in address" unless shopify_order.customer.default_address&.address1&.present?

            # # Currently only new customers receive postcards
            # next puts "customer already exists" if order.customer.postcards.where(data_source_status: "history").count > 0

            # default_address = shopify_order.customer.default_address
            # international = default_address.country_code != "US"

            # # Create a new card
            # post_sale_order = shop.card_orders.find_by(type: "PostSaleOrder")
            # post_sale_order.prepare_for_sending(order, "history")
          end

          break unless shopify_orders.next_page?
          shopify_orders = shopify_orders.fetch_next_page
        end

        # =================================================
        # Fetching Customer data from shopify
        # =================================================
        customers_before = campaign.automation? ? Time.new.strftime("%FT%T%:z") : campaign.created_at
        customers = ShopifyAPI::Customer.where(
          created_at_max: customers_before,
          limit: 250,
        )

        # Set customer filter
        filter = campaign.filters.last
        filter = Filter.new(filter_data: {:accepted => {}, :removed => {}}) if filter.blank?
        customer_targeting_service =  CustomerTargetingService.new({shop: shop}, filter.filter_data[:accepted], filter.filter_data[:removed])

        # Get already exisiting customer in postcard list => 1 customer only sent 1 postcard
        # This is for use case when we go from paused status to processing
        existing_customers = campaign.postcards
        while true
          customers.each do |c|
            begin
              customer = Customer.from_shopify!(c)
            rescue StandardError => e
              # If there is an error such as Nil:NilClass
              # This rescue is to log the error and keep the system going
              Rails.logger.debug "[ERROR] #{e.class} #{e.message}"
              next
            end
            # If customer don't pass filter then skip
            next unless (customer_targeting_service.customer_pass_filter?(customer.id) &&
                        !(customer.international? ^ campaign.international) &&
                        !existing_customers.exists?(customer_id: customer.id)
                        )
            postcard = Postcard.new
            postcard.customer = customer
            postcard.send_date = Time.now.beginning_of_day > campaign.send_date_start ? Time.now : campaign.send_date_start

            campaign.postcards << postcard

            postcard.save!
          end

          break unless customers.next_page?
          customers = customers.fetch_next_page
        end
        shop.update(shopify_history_data_imported: DateTime.now)

        # begin
        result = true
        # Get postcard paid
        campaign.postcards.find_each do |postcard|
          result = PaymentService.pay_postcard_for_campaign_monthly campaign.shop, campaign, postcard
          break unless result
        end

        # rescue
        #   campaign.error!
        # end

        if campaign.enabled?
          if Time.now.end_of_day < campaign.send_date_start
            campaign.scheduled!
          else
            campaign.sending! if result
          end
        end
      when "scheduled"
        Rails.logger.debug ">>>>>>>>>>>>>>>>>>>>>> [NOTE] Scheduling"

        if campaign.enabled?
          if Time.now.end_of_day < campaign.send_date_start
            wait_time = 1.day
          else
            campaign.sending!
          end
        end

      when "sending"
        Rails.logger.debug ">>>>>>>>>>>>>>>>>>>>>> [NOTE] Sending"

        result = Postcard.send_all campaign.id
        Rails.logger.debug "There are error in sending process" if result[:card_sent_amount] < result[:total_card]
        campaign.save!

        if campaign.enabled?
          if (reach_end_date(campaign) || campaign.one_off?)
            campaign.complete!
          else
            wait_time = 1.day
            reset_status_to_processing_in_new_loop = true
          end
        end
      else
        Rails.logger.debug "[NOTE] Campaign with id #{campaign.id} has status #{campaign.campaign_status}"
      end
    end
    SendingPostcardJob.set(wait: wait_time).perform_later(shop, campaign, reset_status_to_processing_in_new_loop)
  end


  private

    def reach_end_date campaign
      return false if campaign.send_continuously

      Time.now.beginning_of_day >= campaign.send_date_end
    end
end