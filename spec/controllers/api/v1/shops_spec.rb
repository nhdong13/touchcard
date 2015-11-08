describe API::V1::ShopsController do
  require 'spec_helper'
  include SpecTestHelper

  let(:shop) { create(:shop) }

  describe "Get shop" do

    describe "without session" do

      it "should respond with 302" do
        get :show, id: shop.id

        expect(response.status).to eq(302)

      end
    end

    describe "with a session" do

      it "should respond with 200" do
        login(shop)
        get :show, id: shop.id
        expect(response.status).to eq(200)
      end

      it "should respond with shop data" do
        login(shop)
        get :show, id: shop.id
        json = JSON.parse(response.body)
        expect(json['shop']['id']).to eq(shop.id)
      end
    end
  end

  describe "Update a Shop" do

    describe "with an ivalid param" do

      # TODO: figure out why this is returning 200
      it "should respond with 422" do
        login(shop)
        patch :update, id: shop.id, :shop => {id: shop.id, token: true }
        expect(response.status).to eq(422)
      end
    end

    describe "with valid params" do

      it "should respond with 200" do
        login(shop)
        patch :update, id: shop.id, :shop => {id: shop.id, last_month: 100 }
        expect(response.status).to eq(200)
      end

      it "should update the data" do
        login(shop)
        patch :update, id: shop.id, :shop => {id: shop.id, last_month: 100 }
        json = JSON.parse(response.body)
        expect(json['shop']['last_month']).to eq(100)
      end
    end
  end
end
