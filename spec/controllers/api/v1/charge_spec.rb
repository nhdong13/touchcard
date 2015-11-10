describe API::V1::ChargesController do
  require 'spec_helper'
  include SpecTestHelper

  let(:charge)    { create(:charge) }
  let(:charge2)   { create(:charge, shop => charge.shop) }

  describe ":index" do
    context "not loggeed on" do
      it "should have status 302" do
        get :index

        expect(response.status).to eq(302)
      end
    end

    context "logged in" do
      it "should have status 200" do
        login(charge.shop)
        get :index

        expect(response.status).to eq(200)
      end
    end
  end

  describe ":show" do
    context "not logged in" do
      it "should have status 302" do
        get :show, id: charge.id

        expect(response.status).to eq(302)
      end
    end
    context "while logged in" do

      context "with invalid id" do
        it "should have status 404" do
          login(charge.shop)
          get :show, id: (charge.id + 1)

          expect(response.status).to eq(404)
        end
      end

      context "with valid id" do
        it "should have status 200" do
          login(charge.shop)
          get :show, id: charge.id

          expect(response.status).to eq(200)
        end

        it "should have charge id" do
          login(charge.shop)
          get :show, id: charge.id
          json = JSON.parse(response.body)

          expect(json['charge']['id']).to eq(charge.id)
        end
      end
    end
  end

  describe "Create Charge" do
    context "while logged out" do
      it "should have status 302" do
        post :create, :charge => { shop_id: charge.shop_id }

        expect(response.status).to eq(302)
      end
    end

    describe "while logged in" do
      context "with invalid params" do
        it "should have status 422" do
          login(charge.shop)
          post :create, :charge => { recurring: true, amount: 10 }

          expect(response.status).to eq(422)
        end
      end

      # TODO: This relies on creating a real shopify charge
#     describe "with valid params" do
#       it "should have status 200" do
#         login(charge.shop)
#         post :create, :charge => { shop_id: charge.shop_id }

#         expect(response.status).to eq(200)
#       end
#     end
    end
  end
  describe "Update charge" do
    context "while logged out" do
      it "should have status 302" do
        patch :update, id: charge.id, :charge => { amount: 100 }

        expect(response.status).to eq(302)
      end
    end

    context "while logged in" do
      context "with invalid params" do
        it "should respond with 422" do
          login(charge.shop)
          patch :update, id: charge.id, :charge => { id: charge.id, shop_id: nil }

          expect(response.status).to eq(422)
        end
      end

      context "with valid params" do
        it "should have status 200" do
          login(charge.shop)
          patch :update, id: charge.id, :charge => { id: charge.id, amount: 100 }

          expect(response.status).to eq(200)
        end

        it "should have new amount" do
          login(charge.shop)
          patch :update, id: charge.id, :charge => { id: charge.id, amount: 100 }
          json = JSON.parse(response.body)

          expect(json['charge']['amount']).to eq(100)
        end

      end
    end
  end
end
