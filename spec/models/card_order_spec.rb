require 'rails_helper'

RSpec.describe CardOrder, type: :model do
  describe "#prepare_for_sending" do
    it "adds new postcard for sending abandoned cards" do
      customer = create(:customer)
      customer.addresses.create(address1: "Test", country_code: "US")
      checkout = create(:checkout, customer: customer)
      card = create(:card_order, type: "AbandonedCard")

      card.prepare_for_sending(checkout)

      expect(Postcard.count).to eq 1
    end

    it "doesn't add international postcard if shop is not sending
        international" do
      customer = create(:customer)
      customer.addresses.create(address1: "Test", country_code: "UK")
      checkout = create(:checkout, customer: customer)
      card = create(:card_order, type: "AbandonedCard", international: false)

      card.prepare_for_sending(checkout)

      expect(Postcard.count).to eq 0
    end

    it "doesn't add postcard if the shop can't afford it" do
      customer = create(:customer)
      shop = create(:shop, credit: 0)
      customer.addresses.create(address1: "Test", country_code: "UK")
      checkout = create(:checkout, customer: customer, shop: shop)
      card = create(:card_order, type: "AbandonedCard", international: false)

      card.prepare_for_sending(checkout)

      expect(Postcard.count).to eq 0
    end
  end
end
