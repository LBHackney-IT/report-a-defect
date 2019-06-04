FactoryBot.define do
  factory :defect do
    description { Faker::Lorem.paragraph_by_chars(750) }
    contact_name { Faker::Name.name }
    contact_email_address { Faker::Internet.email }
    contact_phone_number { Faker::Base.numerify('###########') }
    trade { Defect::TRADES.sample }
    target_completion_date { (1..10).to_a.sample.days.from_now }
    status { Defect.statuses.keys.sample }
    reference_number { SecureRandom.hex(3).upcase }

    association :property, factory: :property
    association :priority, factory: :priority

    trait :with_comments do
      after(:create) do |defect|
        create_list(:comment, 3, defect: defect)
      end
    end
  end
end
