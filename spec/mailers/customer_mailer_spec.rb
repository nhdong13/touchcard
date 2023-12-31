require 'rails_helper'

RSpec.describe CustomerMailer do
  describe ".card_arrived_notifiation" do
    before(:each) do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
      @postcard = create(:postcard)
      stub_shop(@postcard.shop.domain)
      CustomerMailer.card_arrived_notification(@postcard).deliver_now
    end

    after(:each) do
      ActionMailer::Base.deliveries.clear
    end

    it "sould send an email" do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it "renders the reciver email" do
      expect(ActionMailer::Base.deliveries.first.to).to eq [@postcard.customer.email]
    end

    it "subject is correctly set" do
      expect(ActionMailer::Base.deliveries.first.subject)
        .to eq "You've got a Postcard from #{@postcard.shop.name}!"
    end

    it "renders the sender mail correctly" do
      expect(ActionMailer::Base.deliveries.first.from).to eq [ENV["MAIL_FROM"]]
    end
  end
end

def stub_shop(domain)
  response_text = File.read(
    "#{Rails.root}/spec/fixtures/shopify/shop/shop.json")
  response_obj = JSON.parse(response_text)
  stub_request(:get, "https://#{domain}/admin/shop.json")
    .to_return(body: response_obj.to_json)
end
