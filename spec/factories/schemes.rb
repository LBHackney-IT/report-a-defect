FactoryBot.define do
  factory :scheme do
    name { Faker::GreekPhilosophers.name }
    contractor_name { Faker::GreekPhilosophers.name }
    contractor_email_address { Faker::Internet.email }
    employer_agent_name { Faker::GreekPhilosophers.name }
    employer_agent_email_address { Faker::Internet.email }
    association :estate, factory: :estate
  end
end
