FactoryGirl.define do
  factory :address do
    address1 "MyText"
    address2 "MyText"
    city "MyText"
    company "MyText"
    country "United States"
    country_code "US"
    first_name "MyString"
    last_name "MyString"
    latitude 1.5
    longitude 1.5
    phone "MyText"
    province "MyText"
    zip "MyText"
    name "MyString"
    text "MyString"
    province_code "MyString"
  end

  factory :order do
    shopify_id 1
    browser_ip "MyString"
    discount_codes "MyText"
    financial_status "MyString"
    fulfillment_status "MyString"
    tags "MyText"
    landing_site "MyText"
    referring_site "MyText"
    total_discounts 1
    total_line_items_price 1
    total_price 1
    total_tax 1
    processing_method "MyString"
    processed_at "2015-12-02 16:49:13"
    customer nil
  end

  factory :customer do
    shopify_id "MyString"
    first_name "MyString"
    last_name "MyString"
    email ""
    verified_email false
    total_spent 1.5
    tax_exempt false
    tags "MyText"
    state "MyString"
    orders_count 1
    note "MyText"
    last_order_name "MyText"
    last_order_id "MyString"
    accepts_marketing false
  end

  factory :subscription do
    quantity 1
    plan nil
    shop nil
  end

  factory :plan do
    stripe_id 1
    amount 1
    interval "MyString"
    name "MyString"
    interval_count 1
    trial_period_days 1
  end

  factory :card_side do
    image "MyText"
    is_back false
  end

  factory :shop do
    sequence(:domain) { |n| "testshop#{n}.myshopify.com" }
    sequence(:token) { |n| "shopif_token_#{n}" }
  end

  factory :card_order do
    enabled true
    type "PostSaleOrder"
    shop
    association :card_side_front, factory: :card_side
    association :card_side_back, factory: :card_side
  end

  factory :postcard do
    card_order
    order
    customer
    paid true
    sent true
  end

  factory :charge do
    shop
    recurring true
    card_order
    amount 1
    last_page "last_page"
    status "new"
  end
end
