require 'rails_helper'

RSpec.describe Postcard, type: :model do
  let(:customer) { postcard.customer }
  let!(:address) { create(:address, customer: customer) }
  let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }
  let(:card_order) { create(:card_order, discount_pct: 10, discount_exp: 2) }
  let(:shop) { card_order.shop }
  let!(:discount) { stub_shopify(:discounts, :create) }

  describe "#send_card" do
    # TODO: split out spec into seperate cases
    # TODO: handle negative cases
    it "works" do
      stub_request(:post, "https://#{ENV['LOB_API_KEY']}:@api.lob.com/v1/postcards")
        .to_return(body: File.read("#{Rails.root}/spec/fixtures/lob/postcards/create/default.json"))
      postcard.send_card
      expect(postcard.sent).to eq true
      expect(postcard.date_sent).to eq Date.today
      # XXX: because comparison is to noon small probability of failure if run exactly at midnight
      expect(postcard.estimated_arrival.noon).to eq 5.business_days.from_now.noon
      expect(postcard.postcard_id).to eq "psc_14c1b66f31264c34"
    end
  end
end
