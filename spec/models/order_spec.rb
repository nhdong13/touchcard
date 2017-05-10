require "rails_helper"

RSpec.describe Order, type: :model do
  describe "#connect_to_postcard" do
    let(:order) { create(:order, discount_codes: [{ "code" => "ABC-DEF-GHI", "amount" => "10.00", "type" => "percentage" }]) }
    let!(:postcard) { create(:postcard, discount_code: "ABC-DEF-GHI") }

    it "connects order to postcard based on discount code" do
      is_order_connected_to_postcard?
    end

    it "connects order to postcard based on lowercase discount code" do
      order.discount_codes.first["code"] = "abc-def-ghi"
      is_order_connected_to_postcard?
    end

    it "connects order to postcard based on mixed cased discount code" do
      order.discount_codes.first["code"] = "abc-DEF-ghi"
      is_order_connected_to_postcard?
    end

    it "connects order to postcard based on capitalized discount code" do
      order.discount_codes.first["code"] = "Abc-def-ghi"
      is_order_connected_to_postcard?
    end

    it "connects order to postcard based on ALL CAPS discount code" do
      order.discount_codes.first["code"] = "ABC-DEF-GHI"
      is_order_connected_to_postcard?
    end
  end
end

def is_order_connected_to_postcard?
  new_postcard = order.connect_to_postcard
  expect(new_postcard).to eq postcard
end
