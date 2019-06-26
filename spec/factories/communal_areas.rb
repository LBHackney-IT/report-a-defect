FactoryBot.define do
  factory :communal_area do
    name { Faker::Address.community }
    association :scheme, factory: :scheme
  end
end
