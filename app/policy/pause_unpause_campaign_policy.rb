=begin
  This class hide all detail about condition
  a campaign have to satify when user want to pause or unpause
=end
class PauseUnpauseCampaignPolicy
  class << self
    # Hide all condition a campaign have to satify in order to unpause
    # Campaign's enabled field must go from false => true
    #
    # params:
    #   \campaign_enabled_field_before_change
    #     Must be boolean
    #
    #   \campaign_enabled_field_after_change
    #     Must be boolean
    #
    def enable_campaign? campaign_enabled_field_before_change, campaign_enabled_field_after_change
      ((campaign_enabled_field_before_change ^ campaign_enabled_field_after_change) && campaign_enabled_field_after_change)
    end

    # Hide all condition a campaign have to satify in order to pause
    # Campaign's enabled field must go from true => false
    #
    # params:
    #   \campaign_enabled_field_before_change
    #     Must be boolean
    #
    #   \campaign_enabled_field_after_change
    #     Must be boolean
    #
    def disable_campaign? campaign_enabled_field_before_change, campaign_enabled_field_after_change
      ((campaign_enabled_field_before_change ^ campaign_enabled_field_after_change) &&
        !campaign_enabled_field_after_change)
    end

    # Hide all condition a campaign have to satify to become passed campaign
    # a passed campaign is a campaign has an end date but didn't finish sending postcard yet
    # and that end date has been due
    #
    # params:
    #   \campaign
    #     Card order instance
    #
    def passed_campaign? campaign
      # for now the campaign only has 2 types: automation and one-off. If there is any change of that in future
      # this if-else have to change
      if campaign.automation?
        !campaign.send_continuously && Time.now > campaign.send_date_end
      else
        Time.now > campaign.send_date_start
      end
    end
  end
end