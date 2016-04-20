FactoryGirl.define do
	sequence :email do |n|
    "test#{n}@example.com"
	end

  factory :line_item do
    order
    name "Test Product"
    sequence(:shopify_id)
  end

  factory :stripe_event do
    stripe_id "evt_thisisanid"
    status "processing"
  end

  factory :filter do
    card_order
    filter_data { { "minimum" => 0, "maximum" => 1000 } }
  end

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
    province "New York"
    zip "MyText"
    name "MyString"
    text "MyString"
    province_code "NY"
    sequence(:shopify_id)
  end

  factory :order do
    sequence(:shopify_id)
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
    shop
  end

  factory :customer do
    sequence(:shopify_id) { |n| "CustomerId#{n}" }
    first_name "MyString"
    last_name "MyString"
    email
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
    plan
    shop
  end

  factory :plan do
    amount 99
    name "Test Plan"
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
    association :card_side_front, factory: :card_side
    shop
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
