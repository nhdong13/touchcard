require "slack_notify"

class SlackNotifyJob < ActiveJob::Base
  queue_as :default

  def perform(shop)
    SlackNotify.install(shop.domain, shop.email, shop.owner, shop.last_month)
  end
end
