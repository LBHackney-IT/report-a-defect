FactoryBot.define do
  factory :defect do
    description { Faker::Lorem.sentences(2) }
    contact_name { Faker::Name.name }
    contact_email_address { Faker::Internet.email }
    contact_phone_number { Faker::PhoneNumber }
    trade { Defect::TRADES.sample }
    target_completion_date { (1..10).to_a.sample.days.from_now }
    status { Defect.statuses.keys.sample }
    reference_number { SecureRandom.hex(3).upcase }

    association :property, factory: :property
    association :priority, factory: :priority
  end
end
