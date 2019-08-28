require "rest_client"

class SendToSlackJob < ActiveJob::Base
  queue_as :default

  def perform(payload)
    # TeamTouchcard
    RestClient.post(ENV["SLACK_URL"], payload.to_json)
  end
end
