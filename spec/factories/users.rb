FactoryBot.define do
  factory :user do
    identifier { SecureRandom.uuid }
    name { Faker::GreekPhilosophers.name }
  end
end
