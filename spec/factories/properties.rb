FactoryBot.define do
  factory :property do
    address { Faker::Address.street_address }
    postcode { Faker::Address.zip_code }
    uprn { Faker::Number.number(digits: 12) }
    association :scheme, factory: :scheme
  end
end
