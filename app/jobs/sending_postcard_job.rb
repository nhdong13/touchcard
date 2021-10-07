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

        is_there_error_when_creating_postcard = false
        # Get already exisiting customer in postcard list => 1 customer only sent 1 postcard
        # This is for use case when we go from paused status to processing
        existing_customers = campaign.postcards
        shop.customers.where("customers.created_at < ?", customers_before).find_each do |customer|
          # If customer don't pass filter then skip
          begin
            # Rails.logger.debug ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
            # Rails.logger.debug "#{customer_targeting_service.customer_pass_filter?(customer.id)} + #{!(customer.international? ^ campaign.international)} + #{!existing_customers.exists?(customer_id: customer.id)} = #{(customer_targeting_service.customer_pass_filter?(customer.id) &&
            #           !(customer.international? ^ campaign.international) &&
            #           !existing_customers.exists?(customer_id: customer.id)
            #           )}"
            next unless (customer_targeting_service.customer_pass_filter?(customer.id) &&
                      !(customer.international? ^ campaign.international) &&
                      !existing_customers.exists?(customer_id: customer.id)
                      )
          rescue => e
            campaign.postcards << Postcard.create(error: e.message)
            is_there_error_when_creating_postcard = true
            next
          end

          postcard = Postcard.new
          postcard.customer = customer

          blank_required_fields = {first_name: customer.default_address.first_name.present?, last_name: customer.default_address.last_name.present?, 
            address1: customer.default_address.address1.present?, 
            city: customer.default_address.city.present?, 
            province: customer.default_address.province_code.present?, 
            country: customer.default_address.country_code.present?,
            zip: customer.default_address.zip.present?}
          
          if blank_required_fields.has_value?(false)
            error_fields = []
            blank_required_fields = blank_required_fields.filter {|key, value| value == false}
            blank_required_fields.each_key {|key| error_fields << key.to_s.split("_").join(" ").capitalize}
            error_message = "Missing " + error_fields.join(", ")

            postcard.error = error_message
            is_there_error_when_creating_postcard = true
          else
            postcard.send_date = Time.now.beginning_of_day > campaign.send_date_start ? Time.now : campaign.send_date_start
          end

          campaign.postcards << postcard
          postcard.save!
        end

        ReportErrorMailer.send_error_report(campaign).deliver_later if is_there_error_when_creating_postcard

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
          campaign.postcards.can_send.find_each do |postcard|
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