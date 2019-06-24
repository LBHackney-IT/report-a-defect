FactoryBot.define do
  factory :defect do
    title { Faker::Lorem.paragraph_by_chars(50) }
    description { Faker::Lorem.paragraph_by_chars(750) }
    access_information { Faker::Lorem.paragraph_by_chars(250) }
    contact_name { Faker::Name.name }
    contact_email_address { Faker::Internet.email }
    contact_phone_number { Faker::Base.numerify('###########') }
    trade { Defect::TRADES.sample }
    target_completion_date { (1..10).to_a.sample.days.from_now }
    status { Defect.statuses.keys.sample }
    reference_number { SecureRandom.hex(3).upcase }

    association :priority, factory: :priority

    factory :property_defect do
      communal { false }
      association :property, factory: :property
    end

    factory :communal_defect do
      communal { true }
      association :block, factory: :block
    end

    trait :with_comments do
      after(:create) do |defect|
        create_list(:comment, 3, defect: defect)
      end
    end
  end
end
