require 'rest_client'

class SlackNotify
  def self.install(domain)
    payload = {
      text: "A new shop has installed Touchcart: #{domain}"
    }
    send_to_slack(payload)
  end

  def self.uninstall(domain)
    payload = {
      text: "A shop has uninstalled RPC: #{domain}."
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

  def send_to_slack(payload)
    @slack_url = "https://hooks.slack.com/services/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"
    resp = RestClient.post(slack_url, payload.to_json)
    resp.code
  end
end
