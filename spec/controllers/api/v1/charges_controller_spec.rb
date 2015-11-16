require 'rails_helper'

describe Api::V1::ChargesController do
  let(:json) { JSON.parse(response.body) }
  let(:shop) { create(:shop) }
  let(:other_shop) { create(:shop) }

  let(:charge)    { create(:charge, shop: shop) }
  let(:charge2)   { create(:charge, shop: charge.shop) }

  let(:create_params) { { card_order_id: 1, amount: 3, last_page: 'test' } }
  let(:expected_params) { create_params.with_indifferent_access }

  context "when not signed in" do
    describe "#create" do
      it '401s' do
        post :create, charge: create_params
        expect(response.status).to eq(401)
      end
    end

    describe "#show" do
      it '401s' do
        get :show, id: charge.id
        expect(response.status).to eq(401)
      end
    end

    describe "#update" do
      it '401s' do
        put :update, id: charge.id
        expect(response.status).to eq(401)
      end
    end
  end

  context "when signed in" do
    before(:each) { session[:shopify] = shop.id }
    describe "#show" do
      context "when charge does not exist" do
        it "should have status 404" do
          get :show, id: -1
          expect(response.status).to eq(404)
        end
      end

      it "succeeds" do
        get :show, id: charge.id
        expect(response.status).to eq(200)
      end

      it "should have required params" do
        get :show, id: charge.id
        expect(json['charge']).to include(charge.attributes.slice(
          'id', 'amount', 'status', 'card_order_id'))
      end
    end

    describe "#create" do
      context "with invalid params" do
        it "should have status 422" do
          post :create, charge: { amount: 10 }
          expect(response.status).to eq(422)
        end
      end

      # TODO: This relies on creating a real shopify charge
      # describe "with valid params" do
      #   it "should have status 200" do
      #     post :create, :charge => { shop_id: charge.shop_id }
      #
      #     expect(response.status).to eq(200)
      #   end
      # end
    end

    describe "#update" do
      # This needs to hit the shopify api
      # it "should have status 200" do
      #   put :update, id: charge.id, charge: { id: charge.id, status: "canceled" }
      #   expect(response.status).to eq(200)
      # end

      # it should block changing the status to something that is not canceled
    end
  end
end
