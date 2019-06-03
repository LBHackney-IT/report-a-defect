FactoryBot.define do
  factory :property do
    core_name { Faker::Address.community }
    address { Faker::Address.street_address }
    postcode { Faker::Address.zip_code }
    uprn { Faker::Number.number(12) }
    association :scheme, factory: :scheme
  end
end
