require "rails_helper"

RSpec.describe Api::V1::SubscriptionsController, type: :controller do
  let!(:customer_show) { stub_stripe("customers", :show) }
  let!(:subcription_create) do
    stub_stripe("subscriptions", :create,
      entity_uri: "customers/#{customer_show[:id]}/subscriptions",
      overrides: { customer: customer_show[:id] })

    stub_request(:post, /#{ENV['AC_ENDPOINT']}/).
        with(:body => {"p"=>["9"]}).
        to_return(:status => 200, :body => "{}", :headers => {})
  end
  let!(:subcription_update) do
    stub_stripe("subscriptions", :update,
      entity_uri: "customers/#{customer_show[:id]}/subscriptions",
      overrides: { quantity: 20, customer: customer_show[:id] })
  end
  let!(:subscription_destroy) do
    stub_stripe("subscriptions", :destroy,
      entity_uri: "customers/#{customer_show[:id]}/subscriptions",
      overrides: { customer: customer_show[:id] })
  end
  let!(:subscription_show) do
    stub_stripe("subscriptions", :show,
      entity_uri: "customers/#{customer_show[:id]}/subscriptions",
      overrides: { customer: customer_show[:id] })
  end
  let!(:invoiceitem_create) { stub_stripe("invoiceitems", :create) }

  let(:json) { JSON.parse(response.body) }
  let(:shop) { create(:shop, stripe_customer_id: customer_show[:id]) }
  let(:other_shop) { create(:shop) }
  let(:plan) { create(:plan) }
  let(:subscription) { inst = Subscription.create(plan: plan, shop: shop, quantity: 10) }
  let(:subscription_params) { { plan_id: plan.id, quantity: 10 } }
  let(:subscription_update_params) { { quantity: 20 } }

  context "when not signed in" do
    describe "#show" do
      it "401s" do
        get :show, id: subscription.id
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end

    describe "#update" do
      it "401s" do
        put :update, id: subscription.id, subscription: subscription_params
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end

    describe "#create" do
      it "401s" do
        put :create, subscription: subscription_params
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end
  end

  context "when signed in" do
    before(:each) { session[:shopify] = shop.id }

    context "when subscription does not exist" do
      describe "#update" do
        it "404s" do
          put :update, id: -1, subscription: subscription_params
          expect(response.status).to eq(404)
          expect(json).to include("errors")
        end
      end

      describe "#show" do
        it "404s" do
          put :show, id: -1
          expect(response.status).to eq(404)
          expect(json).to include("errors")
        end
      end
    end

    context "when subscription not owned by user" do
      before(:each) { subscription.update_attributes!(shop: other_shop) }
      describe "#update" do
        it "401s" do
          put :update, id: subscription.id, subscription: subscription_params
          expect(response.status).to eq(401)
          expect(json).to include("errors")
        end
      end

      describe "#show" do
        it "401s" do
          put :show, id: subscription.id
          expect(response.status).to eq(401)
          expect(json).to include("errors")
        end
      end
    end

    describe "#create" do
      context "when plan does not exist" do
        it "422s" do
          post :create, subscription: { plan_id: -1, quantity: 10 }
          expect(response.status).to eq(422)
          expect(json).to include("errors")
        end
      end

      it "works" do
        post :create, subscription: subscription_params
        expect(response.status).to eq(200)
      end

      it "sets shop credits" do
        post :create, subscription: subscription_params
        expect(Shop.find(shop.id).credit).to eq(subscription_params[:quantity])
      end
    end

    describe "#show" do
      let(:expected_params) { subscription.attributes.slice("id", "plan_id", "quantity") }

      context "when subscription owned by user" do
        before(:each ) { get :show, id: subscription.id }

        it "succeeds" do
          expect(response.status).to eq(200)
        end

        it "includes id and subscription_data" do
          expect(json["subscription"]).to include(expected_params)
        end
      end
    end

    describe "#update" do
      before(:each) { put :update, id: subscription.id, subscription: subscription_update_params }

      it "succeeds" do
        expect(response.status).to eq(200)
      end

      it "changes quantity" do
        db_subscription = Subscription.find(subscription.id)
        expect(db_subscription.quantity).to eq(20)
      end
    end
  end
end
