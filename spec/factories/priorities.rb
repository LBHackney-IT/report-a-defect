FactoryBot.define do
  factory :priority do
    name { ['Priority 1', 'Priority 2', 'Priority 3'].sample }
    duration { ['1 day', '3 days', '5 days', '1 month'].sample }
    association :scheme, factory: :scheme
  end
end
