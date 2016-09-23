require 'rails_helper'

RSpec.describe CustomerMailer do
  describe ".send_coupon_expiration_notification" do
    before(:each) do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
      @postcard = create(:postcard)
      @postcard.update_attributes(discount_code: "A01-CODE", discount_pct: 10, discount_exp_at:  Time.now + 1.days)

      stub_shop(@postcard.shop.domain)
      CustomerMailer.send_coupon_expiration_notification(@postcard).deliver_now
    end

    after(:each) do
      ActionMailer::Base.deliveries.clear
    end

    it "should send an email" do
      expect(ActionMailer::Base.deliveries.count).to eq 1
    end

    it "renders the reciver email" do
      expect(ActionMailer::Base.deliveries.first.to).to eq [@postcard.customer.email]
    end

    it "subject is correctly set" do
      expect(ActionMailer::Base.deliveries.first.subject)
        .to eq "Coupon from #{@postcard.shop.name}!"
    end

    it "renders the sender mail correctly" do
      expect(ActionMailer::Base.deliveries.first.from).to eq [ENV["MAIL_FROM"]]
    end

    it "renders the discount code correctly" do
      expect(ActionMailer::Base.deliveries.first.body).to include "A01-CODE"
    end

    it "renders the discount value correctly" do
      expect(ActionMailer::Base.deliveries.first.body).to include "10% OFF"
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
