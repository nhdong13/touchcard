require 'rails_helper'
require 'discount_manager'

RSpec.describe DiscountManager do
  let!(:card_order) { create(:card_order, { discount_pct: -15, discount_exp: 2.weeks.from_now }) }
  let(:path) { card_order.shop.shopify_api_path }
  let(:value) { card_order.discount_pct }
  let(:expire_at) { card_order.discount_exp }
  let(:shop) { card_order.shop }
  let(:discount_manager) { DiscountManager.new(path, value, expire_at) }

  it "generates code neccessary for discount" do
    expect(discount_manager.discount_code).to match(/[A-Z]{3}-[A-Z]{3}-[A-Z]{3}/)
  end

  describe "handles creation of price rules and discount" do
    # let!(:discount) { stub_shopify(:discounts, :create) }
    # let!(:price_rule) { stub_shopify(:price_rules, :create) }

    before(:each) do
      stub_shopify(:price_rules, :create)
      stub_shopify(:discounts, :create, discount: true, price_rule_id: discount_manager.price_rule_id)
      discount_manager.create
    end

    it "with successful request for new price rule" do
      expect(discount_manager.price_rule_id).to be_a(Bignum)
    end

    it "creates discount" do
      expect(discount_manager.discount_code).to match(/[A-Z]{3}-[A-Z]{3}-[A-Z]{3}/)
    end
  end
end
