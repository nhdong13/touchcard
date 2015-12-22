require "rails_helper"

RSpec.describe Api::V1::FiltersController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:shop) { create(:shop) }
  let(:other_shop) { create(:shop) }
  let(:card_order) { create(:card_order, shop: shop) }
  let(:filter) { create(:filter, card_order: card_order) }
  let(:filter_data) { { minimum: 100 } }

  context "when not signed in" do
    describe "#show" do
      it "401s" do
        get :show, id: filter.id
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end

    describe "#update" do
      it "401s" do
        put :update, id: filter.id, filter: { filter_data: filter_data }
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end

    describe "#destroy" do
      it "401s" do
        put :destroy, id: filter.id
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end

    describe "#create" do
      it "401s" do
        put :create, card_order_id: card_order.id, filter_data: filter_data
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end
  end

  context "when signed in" do
    before(:each) { session[:shopify] = shop.id }

    context "when filter does not exist" do
      describe "#update" do
        it "404s" do
          put :update, id: -1, filter: { filter_data: filter_data }
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

      describe "#destroy" do
        it "404s" do
          put :destroy, id: -1
          expect(response.status).to eq(404)
          expect(json).to include("errors")
        end
      end
    end

    context "when filter not owned by user" do
      before(:each) { card_order.update_attributes!(shop: other_shop) }
      describe "#update" do
        it "401s" do
          put :update, id: filter.id, filter: { filter_data: filter_data }
          expect(response.status).to eq(401)
          expect(json).to include("errors")
        end
      end

      describe "#show" do
        it "401s" do
          put :show, id: filter.id
          expect(response.status).to eq(401)
          expect(json).to include("errors")
        end
      end

      describe "#destroy" do
        it "401s" do
          put :destroy, id: filter.id
          expect(response.status).to eq(401)
          expect(json).to include("errors")
        end
      end
    end


    describe "#create" do
      context "when card_order does not exist" do
        it "422s" do
          post :create, filter: { card_order_id: -1, filter_data: filter_data }
          expect(response.status).to eq(422)
          expect(json).to include("errors")
        end
      end

      context "when card_order not owned by user" do
        before(:each) { card_order.update_attributes!(shop: other_shop) }
        it "401s" do
          post :create, filter: { card_order_id: card_order.id, filter_data: filter_data }
          expect(response.status).to eq(401)
          expect(json).to include("errors")
        end
      end

      it "works" do
        post :create, filter: { card_order_id: card_order.id, filter_data: filter_data }
        expect(response.status).to eq(200)
      end
    end

    describe "#destroy" do
      it "works" do
        delete :destroy, id: filter.id
        expect(response.status).to eq(200)
      end
    end

    describe "#show" do
      let(:expected_params) { filter.attributes.slice("id", "filter_data") }

      context "when filter owned by user" do
        before(:each ) { get :show, id: filter.id }

        it "succeeds" do
          expect(response.status).to eq(200)
        end

        it "includes id and filter_data" do
          expect(json["filter"]).to include(expected_params)
        end
      end
    end

    describe "#update" do
      before(:each) { put :update, id: filter.id, filter: { filter_data: filter_data } }

      it "succeeds" do
        expect(response.status).to eq(200)
      end

      it "updates filter_data" do
        db_filter = Filter.find(filter.id)
        expect(db_filter.filter_data["minimum"]).to eq("100")
      end
    end
  end
end
