require 'rails_helper'

RSpec.describe Shop, type: :model do
  describe "keeps oauth scopes up to date" do
    let(:shop) { create(:shop) }
    let(:shopify_scope) { ShopifyApp.configuration.scope }

    it "detects that scopes are not up to date" do
      expect(shop.granted_scopes_match?(shopify_scope)).to be_falsy
    end

    it "detects that scopes are up to date" do
      shop.oauth_scopes = shopify_scope
      expect(shop.granted_scopes_match?(shopify_scope)).to be_truthy
    end

    it "can update scopes" do
      expect(shop.oauth_scopes).to be_nil
      shop.update_scopes(shopify_scope)
      expect(shop.oauth_scopes).to eq(shopify_scope)
    end
  end
end
