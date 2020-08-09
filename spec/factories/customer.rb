FactoryBot.define do
  factory :customer do
    email { Faker::Internet.email }
    name { Faker::Name.name_with_middle }
    document_number { Faker::Number.number(digits: 8) }
    phone_number { Faker::Number.number(digits: 11) }
    address { Faker::Address.street_address }
  end
end
