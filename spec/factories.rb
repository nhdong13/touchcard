FactoryGirl.define do
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
