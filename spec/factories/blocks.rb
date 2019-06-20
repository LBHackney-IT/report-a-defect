FactoryBot.define do
  factory :block do
    name { Faker::Address.community }
    association :scheme, factory: :scheme
  end
end
