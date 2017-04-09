require 'rails_helper'

RSpec.describe Postcard, type: :model do
  describe "#send_card" do
    let(:customer) { postcard.customer }
    let!(:address) { create(:address, customer: customer) }
    let(:postcard) { create(:postcard, sent: false, paid: true, card_order: card_order) }
    let(:card_order) { create(:card_order, discount_pct: 10, discount_exp: 2) }
    let(:shop) { card_order.shop }
    let!(:discount) { stub_shopify(:discounts, :create) }

    # TODO: split out spec into seperate cases
    # TODO: handle negative cases
    it "works" do
      stub_request(:post, "https://#{ENV['LOB_API_KEY']}:@api.lob.com/v1/postcards")
        .to_return(body: File.read("#{Rails.root}/spec/fixtures/lob/postcards/create/default.json"))
      postcard.send_card
      expect(postcard.sent).to eq true
      expect(postcard.date_sent).to eq Date.today
      # XXX: because comparison is to noon small probability of failure if run exactly at midnight
      expect(postcard.estimated_arrival.noon).to eq 6.business_days.from_now.noon
      expect(postcard.postcard_id).to eq "psc_14c1b66f31264c34"
    end
  end

  describe ".ready_for_arrival_notification" do
    it "returns list of postcards where arrival_notification_sent is false" do
      postcard = create(:postcard, estimated_arrival: 4.days.ago)
      sent_postcard = create(:postcard,
                             card_order: postcard.card_order,
                             customer: postcard.customer,
                             arrival_notification_sent: true)

      list = Postcard.ready_for_arrival_notification

      expect(list.size).to eq 1
    end

    it "returns list of postcards which arrived more than 3 days ago" do
      postcard = create(:postcard, estimated_arrival: 4.days.ago)
      postcard_not_arrived = create(:postcard,
                             card_order: postcard.card_order,
                             customer: postcard.customer,
                             arrival_notification_sent: false,
                             estimated_arrival: 2.days.ago)

      list = Postcard.ready_for_arrival_notification

      expect(list.size).to eq 1
    end

    it "doesn't return postcards which have not arrived" do
      postcard = create(:postcard, estimated_arrival: 1.days.from_now)

      list = Postcard.ready_for_arrival_notification

      expect(list.size).to eq 0
    end
  end
end
