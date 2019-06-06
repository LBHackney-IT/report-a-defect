FactoryBot.define do
  factory :comment do
    message { Faker::Lorem.paragraph }
    association :user, factory: :user
    association :defect, factory: :defect
  end
end
