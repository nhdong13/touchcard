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

  def perform shop, campaign, new_loop_flag = true
    wait_time = 2.minutes.from_now
    if campaign.enabled?
      case campaign.campaign_status
      when "processing"
        Rails.logger.debug ">>>>>>>>>>>>>>>>>>>>>> [NOTE] Processing"

        # =================================================
        # Fetching Customer data and generate postcard
        # =================================================
        customers_before = campaign.automation? ? Time.now : campaign.created_at

        # Set customer filter
        filter = campaign.filters.last
        filter = Filter.new(filter_data: {:accepted => {}, :removed => {}}) if filter.blank?
        customer_targeting_service =  CustomerTargetingService.new({shop: shop}, filter.filter_data[:accepted], filter.filter_data[:removed])

        # Get already exisiting customer in postcard list => 1 customer only sent 1 postcard
        # This is for use case when we go from paused status to processing
        existing_customers = campaign.postcards
        shop.customers.where("customers.created_at < ?", customers_before).find_each do |customer|
          # If customer don't pass filter then skip
          Rails.logger.debug "********************************"
          Rails.logger.debug "#{customer_targeting_service.customer_pass_filter?(customer.id).inspect} + #{(!(customer.international? ^ campaign.international)).inspect} + #{(!existing_customers.exists?(customer_id: customer.id)).inspect} = #{(customer_targeting_service.customer_pass_filter?(customer.id) &&
                      !(customer.international? ^ campaign.international) &&
                      !existing_customers.exists?(customer_id: customer.id)
                      ).inspect}"
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

        if campaign.enabled?
          if Time.now.end_of_day < campaign.send_date_start
            wait_time = Date.tomorrow().beginning_of_day
            campaign.scheduled!
          else
            campaign.sending!
          end
        end
      when "scheduled"
        Rails.logger.debug ">>>>>>>>>>>>>>>>>>>>>> [NOTE] Scheduling"

        if campaign.enabled?
          if Time.now.end_of_day < campaign.send_date_start
            wait_time = Date.tomorrow().beginning_of_day
          else
            campaign.sending!
          end
        end

      when "sending"
        Rails.logger.debug ">>>>>>>>>>>>>>>>>>>>>> [NOTE] Sending"

        result = true
        # Get postcard paid
        if campaign.automation?
          campaign.postcards.find_each do |postcard|
            result = PaymentService.pay_postcard_for_campaign_monthly shop, campaign, postcard
            break unless result
          end
        elsif campaign.one_off?
          result = PaymentService.pay_for_campaign_one_off shop, campaign
        end

        if (campaign.enabled? && result)
          if (reach_end_date(campaign) || campaign.one_off?)
            EnableDisableCampaignService.disable_campaign campaign, :complete, "#{campaign.campaign_name} is complete"
          else
            wait_time = Date.tomorrow().beginning_of_day
          end
        end
      else
        Rails.logger.debug "[NOTE] Campaign with id #{campaign.id} has status #{campaign.campaign_status}"
      end
    end
    SendingPostcardJob.delay(run_at: wait_time).perform_later(shop, campaign)
  end


  private

    def reach_end_date campaign
      return false if campaign.send_continuously

      Time.now.beginning_of_day >= campaign.send_date_end
    end
end