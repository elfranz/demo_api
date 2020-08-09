FactoryBot.define do
  factory :product do
    title { Faker::Beer.brand }
    description { Faker::Beer.style }
    units_available { Faker::Number.number(digits: 3) }
    unit_price { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    hidden { false }
  end
end
