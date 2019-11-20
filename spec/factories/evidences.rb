FactoryBot.define do
  factory :evidence do
    description { Faker::Lorem.paragraph }
    supporting_file { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'evidence.png'), 'image/png') }
    association :defect, factory: :defect
  end
end
