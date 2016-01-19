require "rails_helper"

RSpec.describe Api::V1::LineItemsController, type: :controller do
  let(:json) { JSON.parse(response.body) }
  let(:shop) { create(:shop) }
  let(:other_shop) { create(:shop) }
  let(:order) { create(:order, shop: shop) }
  let(:line_item) { create(:line_item, order: order) }
  let(:line_item_data) { { minimum: 100 } }

  context "when not signed in" do
    describe "#show" do
      it "401s" do
        get :show, id: line_item.id
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end

    describe "#index" do
      it "401s" do
        get :index
        expect(response.status).to eq(401)
        expect(json).to include("errors")
      end
    end
  end

  context "when signed in" do
    before(:each) { session[:shopify] = shop.id }

    context "when line_item does not exist" do
      describe "#show" do
        it "404s" do
          put :show, id: -1
          expect(response.status).to eq(404)
          expect(json).to include("errors")
        end
      end
    end

    context "when line_item not owned by user" do
      before(:each) { order.update_attributes!(shop: other_shop) }
      describe "#show" do
        it "401s" do
          put :show, id: line_item.id
          expect(response.status).to eq(401)
          expect(json).to include("errors")
        end
      end
    end

    describe "#index" do
      let!(:line_items) { 3.times.map { create(:line_item, order: create(:order, shop: shop)) } }
      it "works" do
        get :index
        expected_ids = line_items.map(&:id).sort
        response_ids = json["line_items"].map { |i| i["id"] }.sort
        expect(response_ids).to eq(expected_ids)
      end

      context "one line item has postcard" do
        before(:each) do
          o = line_items.first.order
          o.update_attributes!(postcard: create(:postcard, order: o))
        end
        it "retrievs only ones with postcards" do
          get :index, belongs: true
          expect(json["line_items"].map { |i| i["id"] }).to eq([line_items.first.id])
        end
      end
    end

    describe "#show" do
      let(:expected_params) { line_item.attributes.slice("id", "line_item_data") }

      context "when line_item owned by user" do
        before(:each ) { get :show, id: line_item.id }

        it "succeeds" do
          expect(response.status).to eq(200)
        end

        it "includes id and line_item_data" do
          expect(json["line_item"]).to include(expected_params)
        end
      end
    end
  end
end
