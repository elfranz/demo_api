FactoryBot.define do
  factory :order_product do
    order
    product
    quantity { Faker::Number.number(digits: 4) }
  end
end
