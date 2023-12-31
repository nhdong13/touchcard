require 'rails_helper'
require 'discount_manager'

RSpec.describe DiscountManager do
  let(:card_order) { create(:card_order, { discount_pct: -15, discount_exp: 2 }) }
  let(:path) { card_order.shop.shopify_api_path }
  let(:value) { card_order.discount_pct }
  let(:expire_at) { Time.current.end_of_day + card_order.discount_exp.weeks + 7.days }
  let(:shop) { card_order.shop }
  let(:discount_manager) { DiscountManager.new(path, value, expire_at) }

  it "generates code neccessary for discount" do
    expect(discount_manager.discount_code).to match(/[A-Z]{3}-[A-Z]{3}-[A-Z]{3}/)
  end

  it "generates price rule and discount when values for percentage and expire date exist" do
    price_rule_id = stub_shopify(:price_rules, :create)[:price_rule][:id]
    stub_shopify(:discounts, :create, entity_uri: "price_rules/#{price_rule_id}/discount_codes")

    discount_manager.generate_discount

    expect(discount_manager.price_rule_id).to eq(price_rule_id)
    expect(discount_manager.has_valid_code?).to be_truthy
  end

  # it "generates custom discount when rules values are passed" do
  #   price_rule_id = stub_shopify(:price_rules, :create, {example: :custom_collection})[:price_rule][:id]
  #   stub_shopify(:discounts, :create, entity_uri: "price_rules/#{price_rule_id}/discount_codes")
  #
  #   rules = { target_selection: "entitled",
  #             entitled_collection_ids: [157410590831] }
  #
  #   discount_manager = DiscountManager.new(path, value, expire_at, rules)
  #   discount_manager.generate_discount
  #
  #   # Note: Price rule contents aren't accessible, so we're not actually testing for anything meaningful here.
  #   expect(discount_manager.price_rule_id).to eq(price_rule_id)
  #   expect(discount_manager.has_valid_code?).to be_truthy
  # end

  it "raises error when discount value is missing" do
    expect{ DiscountManager.new(path, nil, card_order.discount_exp) }.to raise_error(RuntimeError)
  end

  it "raises error when expire date is missing" do
    expect{ DiscountManager.new(path, card_order.discount_pct, nil) }.to raise_error(RuntimeError)
  end
end
