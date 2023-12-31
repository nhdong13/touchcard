require 'rest_client'

class SlackNotify

  def self.message(msg_string, run_in_background=false)
    payload = {
        text: "#{msg_string}"
    }
    send_to_slack(payload, run_in_background)
  end

  private

  def self.send_to_slack(payload, run_in_background)
    if run_in_background
      SendToSlackJob.perform_later(payload)
    else
      # TeamTouchcard
      resp = RestClient.post(ENV["SLACK_URL"], payload.to_json)
      resp.code
    end
  end
end