require 'rest_client'

class SlackNotify
  def self.install(domain, email = nil, owner = nil, shop_size = -1)

    # Email, owner, last_month, lob_address
    payload = {
      text: "A new shop has installed Touchcard: #{domain}\nemail: #{email}\nowner: #{owner}\n# new customers: #{shop_size}"
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

  def self.subscriptions_status(quantity)
    payload = {
        text: "Monthly card subscriptions: *#{quantity}* #{ENV["SUBSCRIPTIONS_GOAL_STRING"]}"
    }
    send_to_slack(payload)
  end

  def self.error(domain, error)
    payload = {
      text: "There was a problem with shop: #{domain} at #{Time.now}
      The error was: #{error}"
    }
    send_to_slack(payload)
  end

  private

  def self.send_to_slack(payload)
    return if Rails.env.development?
    # WeeklyWins
    secondary_url = "https://hooks.slack.com/services/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"
    RestClient.post(secondary_url, payload.to_json)

    # TeamTouchcard
    resp = RestClient.post(ENV["SLACK_URL"], payload.to_json)
    resp.code
  end
end
