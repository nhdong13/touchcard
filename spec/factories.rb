FactoryGirl.define do
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
    shop
    association :card_side_front, factory: :card_side
    association :card_side_back, factory: :card_side
  end

  factory :postcard do
    card_order
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
