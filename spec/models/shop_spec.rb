require 'rails_helper'

RSpec.describe Shop, type: :model do
  describe "keeps oauth scopes up to date" do
    let(:shop) { create(:shop) }
    let(:shopify_scope) { ShopifyApp.configuration.scope }

    it "detects that scopes are not up to date" do
      expect(shop.granted_scopes_suffice?(shopify_scope)).to be_falsy
    end

    it "detects that scopes are up to date" do
      shop.oauth_scopes = shopify_scope
      expect(shop.granted_scopes_suffice?(shopify_scope)).to be_truthy
    end

    it "can update scopes" do
      expect(shop.oauth_scopes).to be_nil
      shop.update_scopes(shopify_scope)
      expect(shop.oauth_scopes).to eq(shopify_scope)
    end
    
    it "filters redundant read scopes when write scope exists" do
      scope_string = "read_products, write_products, read_orders"
      normalized_scope_array = ["write_products", "read_orders"]
      expect(shop.normalized_scopes(scope_string)).to eq(normalized_scope_array)
    end
  end
end
