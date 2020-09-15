FactoryBot.define do
  factory :defect do
    title { Faker::Lorem.paragraph_by_chars(50) }
    description { Faker::Lorem.paragraph_by_chars(750) }
    access_information { Faker::Lorem.paragraph_by_chars(250) }
    contact_name { Faker::Name.name }
    contact_email_address { Faker::Internet.email }
    contact_phone_number { Faker::Base.numerify('###########') }
    trade { Defect::TRADES.sample }
    target_completion_date { Faker::Date.between(1.day.from_now, 5.days.from_now) }
    status { Defect.statuses.keys.sample }
    added_at { Time.now.utc }

    association :priority, factory: :priority

    factory :property_defect do
      communal { false }
      association :property, factory: :property
    end

    factory :communal_defect do
      communal { true }
      association :communal_area, factory: :communal_area
    end

    trait :completed do
      status { :completed }
      actual_completion_date { Faker::Date.between(1.day.from_now, 5.days.from_now) }
    end

    trait :with_comments do
      after(:create) do |defect|
        create_list(:comment, 3, defect: defect)
      end
    end
  end
end
