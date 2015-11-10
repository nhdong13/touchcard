FactoryGirl.define do
  factory :card_side do
    image "MyText"
    is_back false
  end

  factory :shop do
    sequence(:domain) { |n| "testshop#{n}.myshopify.com" }
    sequence(:token) { |n| "shopif_token_#{n}" }
  end

  factory :card_template do
    shop
    association :card_side_front, factory: :card_side
    association :card_side_back, factory: :card_side
  end

  factory :postcard do
    card_template
  end

  factory :charge do
    shop
    recurring   true
  end
end
