FactoryBot.define do
  factory :scheme do
    name { Faker::GreekPhilosophers.name }
    association :estate, factory: :estate
  end
end
