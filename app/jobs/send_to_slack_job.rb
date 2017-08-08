require "rest_client"

class SendToSlackJob < ApplicationJob
  queue_as :default

  def perform(payload)
    # WeeklyWins
    secondary_url = "https://hooks.slack.com/services/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"
    RestClient.post(secondary_url, payload.to_json)

    # TeamTouchcard
    RestClient.post(ENV["SLACK_URL"], payload.to_json)
  end
end
