FactoryBot.define do
  factory :communal_area do
    name { Faker::Address.community }
    location { "#{Faker::Address.building_number} - #{Faker::Address.building_number} #{Faker::Address.street_name}" }
    association :scheme, factory: :scheme
  end
end
