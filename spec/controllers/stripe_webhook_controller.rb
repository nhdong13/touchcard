require "rails_helper"

RSpec.describe StripeWebhookController, type: :controller do
  let!(:event_show) { stub_stripe("events", :show) }
  let!(:customer_show) { stub_stripe("customers", :show) }
  let!(:subcription_create) do
    stub_stripe("subscriptions", :create,
      entity_uri: "customers/#{customer_show[:id]}/subscriptions")
  end

  let(:json) { JSON.parse(response.body) }
  let!(:shop) { create(:shop, credit: 0, stripe_customer_id: event_show[:data][:object][:customer]) }
  let(:plan) { create(:plan) }
  let!(:subscription) { Subscription.create(shop: shop, quantity: 1, plan: plan) }

  describe "#create" do
    it "tops up shop" do
      post :create, id: event_show[:id]
      expect(Shop.find(shop.id).credit).to eq subscription.quantity
      expect(StripeEvent.count).to eq 1
      expect(StripeEvent.first.status).to eq "processed"
    end

    context "if event already exists" do
      let!(:stripe_event) { create(:stripe_event, stripe_id: event_show[:id]) }
      it "doesn't do anything" do
        post :create, id: event_show[:id]
        expect(StripeEvent.count).to eq 1
        expect(Shop.find(shop.id).credit).to eq 0
      end
    end
  end
end
