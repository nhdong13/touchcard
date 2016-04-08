require 'rest_client'

class SlackNotify
  def self.install(domain)
    payload = {
      text: "A new shop has installed Touchcard: #{domain}"
    }
    send_to_slack(payload)
  end

  def self.uninstall(domain)
    payload = {
      text: "A shop has uninstalled Touchcard: #{domain}."
      }
    send_to_slack(payload)
  end

  def self.cards_sent(quantity)
    payload = {
        text: "#{quantity} postcards were sent today."
    }
    send_to_slack(payload)
  end

  def self.error(domain, error)
    payload = {
      text: "There was a problem with shop: #{domain} at #{Time.now}. 
      The error was: #{error}"
    }
    send_to_slack(payload)
  end

  private

  def self.send_to_slack(payload)
    # WeeklyWins
    secondary_url = "https://hooks.slack.com/services/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"
    RestClient.post(secondary_url, payload.to_json)

    # TeamTouchcard
    @slack_url = "https://hooks.slack.com/services/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"
    resp = RestClient.post(@slack_url, payload.to_json)
    resp.code
  end
end
