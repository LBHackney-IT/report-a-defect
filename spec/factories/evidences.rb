FactoryBot.define do
  factory :evidence do
    description { Faker::Lorem.paragraph }
    association :defect, factory: :defect
  end
end
