FactoryBot.define do
  factory :user do
    identifier { SecureRandom.uuid }
  end
end
