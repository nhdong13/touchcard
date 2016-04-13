require 'rails_helper'

RSpec.describe Shop, type: :model do
  describe "#name" do
    it "return name of the current shop" do
      shop = create(:shop)
      allow(ShopifyAPI::Shop).to receive(:current)
      allow(shop).to receive(:name).and_return("Name")

      expect(shop.name).to eq "Name"
    end
  end
end
