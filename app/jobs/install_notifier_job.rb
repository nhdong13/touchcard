require "ac_integrator"
require "slack_notify"

class InstallNotifierJob < ActiveJob::Base
  queue_as :default

  def perform(shop)
    ac = AcIntegrator::NewInstall.new

    ac.add_email_to_list(shop.email)
    SlackNotify.install(shop.domain, shop.email, shop.owner, shop.last_month)
  end
end
