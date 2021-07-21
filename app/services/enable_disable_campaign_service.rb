=begin
  In Sending postcard process,
  There are 3 statuses indicate the campaign is enable: Processing, Scheduled, Sending
  4 statuses indicate the campaign is disable: Paused, Error, Out of credit, Complete

  NOTE:
  Draft status indicates this campaign is just created
  For now, we wait for customer's confirmation about Complete status (whether change from Complete => Processing or Sending)

  This class will switch back and forth between statuses indicate the campaign is enable and statuses indicate the campaign is disable
=end
class EnableDisableCampaignService
  class << self
    # Return the campaign to the status before it disable
    # This method will change campaign status in database
    #
    # params:
    #   \campaign
    #     The instance of card order
    #
    #   \message
    #     Message you want to notify user.
    #     If leaves nil, there will be no notify
    #
    def enable_campaign campaign, message
      # This is for a bug happen in old campaign where
      # campaign_status: paused
      # previous_campaign_status: paused
      #
      # NOTE: If in the future, this bug doesn't happen again. We can delete check condition
      # previous_campaign_status == CardOrder.campaign_statuses[:paused]
      if (campaign.previous_campaign_status == CardOrder.campaign_statuses[:paused] || campaign.previous_campaign_status.nil? )
        campaign.previous_campaign_status = CardOrder.campaign_statuses[:processing]
      end

      campaign.campaign_status = campaign.previous_campaign_status
      campaign.save
      # For now cannot use flash in this
      # TODO: need to workaround to notify user
      # flash[:notice] = message if !message.nil?
    end

    # Save current campaign and change it to 1 of 4 statuses indicate the campaign is disable
    # This method will change campaign status in database
    #
    # params:
    #   \campaign
    #     The instance of card order
    #
    #   \disable_status
    #     The status which the campaign will show when disable
    #     This paremeter could be in integer or enum value (see card_order model, enum campaign_status declaration
    #     for more details)
    #
    #   \message
    #     Message you want to notify user.
    #     If leaves nil, there will be no notify
    #
    def disable_campaign campaign, disable_status, message
      # must convert enum value to integer to persist it
      campaign.previous_campaign_status = CardOrder.campaign_statuses[campaign.campaign_status]
      campaign.campaign_status = CardOrder.campaign_statuses[disable_status]
      campaign.save
      # For now cannot use flash in this
      # TODO: need to workaround to notify user
      # flash[:notice] = message if !message.nil?
    end
  end
end