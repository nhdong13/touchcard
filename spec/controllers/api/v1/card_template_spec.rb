describe API::V1::CardTemplatesController do
  require 'spec_helper'
  include SpecTestHelper

  #let (:shop) { create(:shop) }
  let (:card_template) { create(:card_template) }

  describe "Show card_template" do

    describe "with unknown id" do

      it "should respond with 404" do
        login(card_template.shop)
        get :show, id: (card_template.id + 1)

        expect(response.status).to eq(404)
      end
    end

    describe "with known id" do

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
end
