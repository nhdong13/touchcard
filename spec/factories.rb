FactoryGirl.define do
  factory :shop do
    domain  "testshop.myshopify.com"
    token   "123test"
  end

  factory :card_template do
    shop
  end

  factory :postcard do
    card_template
  end
end
