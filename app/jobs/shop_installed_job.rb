require "ac_integrator"
require "slack_notify"

class ShopInstalledJob < ActiveJob::Base
  queue_as :default

  def perform(shop)
    ac = AcIntegrator::NewInstall.new

    tags = []
    size_tag = case shop.last_month
                 when 0...100 then "S"
                 when 100...500 then "M"
                 when 500...1500 then "L"
                 else "XL"
               end
    tags.push(size_tag) if size_tag
    first_name = shop.owner.split(" ", 2).first
    last_name = shop.owner.split(" ", 2).last

    ac.add_contact(shop.email, shop.domain, first_name, last_name, tags)
    SlackNotify.install(shop.domain, shop.email, shop.owner, shop.last_month)
  end
end
