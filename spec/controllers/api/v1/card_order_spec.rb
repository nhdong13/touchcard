describe API::V1::CardOrdersController do
  require 'spec_helper'
  include SpecTestHelper

  #let (:shop) { create(:shop) }
  let (:card_order) { create(:card_order) }

  describe "Show card_order" do

    context "with unknown id" do

      it "should respond with 404" do
        login(card_order.shop)
        get :show, id: (card_order.id + 1)

        expect(response.status).to eq(404)
      end
    end

    context "with known id" do

      it "should respond with 200" do
        login(card_order.shop)
        get :show, id: card_order.id

        expect(response.status).to eq(200)
      end

      it "should return the card_order object" do
        login(card_order.shop)
        get :show, id: card_order.id

        json = JSON.parse(response.body)
        expect(json['card_order']['shop_id']).to eq(card_order.shop_id)
      end
    end
  end

  describe "Create card_order" do

#   describe "With bad params" do
#     it "Should respond with 422" do
#       login(card_order.shop)
#       post :create, :card_order => { style: "thank you" }

#       expect(response.status).to eq(422)
#     end
#   end

    context "With good params" do
      it "should respond with 200" do
        login(card_order.shop)
        post :create, :card_order => { shop_id: card_order.shop.id }

        expect(response.status).to eq(200)
      end
    end
  end

  describe "Update card_order" do

    context "with unknkown id" do
      it "should respond with 404" do
        login(card_order.shop)
        patch :update, id: (card_order.id + 1), :card_order => { id: (card_order.id + 1) }

        expect(response.status).to eq(404)
      end
    end

#   describe "With bad params" do

#     it "should respond with 422" do
#       login(card_order.shop)
#       patch :update, id: card_order.id, :card_order => { id: card_order.id, shop_id: "test" }
#       expect(response.status).to eq(422)
#     end
#   end

    context "with good params" do
      it "should respond with 200" do
        login(card_order.shop)
        patch :update, id: card_order.id, card_order: { id: card_order.id, enabled: true }

        expect(response.status).to eq(200)
      end
    end
  end
end
