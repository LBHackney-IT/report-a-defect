FactoryBot.define do
  factory :priority do
    name { ['Priority 1', 'Priority 2', 'Priority 3'].sample }
    days { [*1..100].sample }
    association :scheme, factory: :scheme
  end
end
