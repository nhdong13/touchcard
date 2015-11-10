describe API::V1::CardTemplatesController do
  require 'spec_helper'
  include SpecTestHelper

  #let (:shop) { create(:shop) }
  let (:card_template) { create(:card_template) }

  describe "Show card_template" do

    context "with unknown id" do

      it "should respond with 404" do
        login(card_template.shop)
        get :show, id: (card_template.id + 1)

        expect(response.status).to eq(404)
      end
    end

    context "with known id" do

      it "should respond with 200" do
        login(card_template.shop)
        get :show, id: card_template.id

        expect(response.status).to eq(200)
      end

      it "should return the card_template object" do
        login(card_template.shop)
        get :show, id: card_template.id

        json = JSON.parse(response.body)
        expect(json['card_template']['shop_id']).to eq(card_template.shop_id)
      end
    end
  end

  describe "Create card_template" do

#   describe "With bad params" do
#     it "Should respond with 422" do
#       login(card_template.shop)
#       post :create, :card_template => { style: "thank you" }

#       expect(response.status).to eq(422)
#     end
#   end

    context "With good params" do
      it "should respond with 200" do
        login(card_template.shop)
        post :create, :card_template => { shop_id: card_template.shop.id }

        expect(response.status).to eq(200)
      end
    end
  end

  describe "Update card_template" do

    context "with unknkown id" do
      it "should respond with 404" do
        login(card_template.shop)
        patch :update, id: (card_template.id + 1), :card_template => { id: (card_template.id + 1) }

        expect(response.status).to eq(404)
      end
    end

#   describe "With bad params" do

#     it "should respond with 422" do
#       login(card_template.shop)
#       patch :update, id: card_template.id, :card_template => { id: card_template.id, shop_id: "test" }
#       expect(response.status).to eq(422)
#     end
#   end

    context "with good params" do
      it "should respond with 200" do
      login(card_template.shop)
      patch :update, id: card_template.id, :card_template => { id: card_template.id, enabled: true }

      expect(response.status).to eq(200)
      end
    end
  end
end
