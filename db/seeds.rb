raise if Rails.env.production?

Comment.delete_all
Defect.delete_all
Property.delete_all
Priority.delete_all
Scheme.delete_all
Estate.delete_all
PublicActivity::Activity.delete_all
User.delete_all

# Estates
estate = FactoryBot.create(:estate, name: 'Kings Cresent')

# Schemes
scheme1 = FactoryBot.create(:scheme, estate: estate, name: '1')
FactoryBot.create(:scheme, estate: estate, name: '2')

# Priorties
priority1 = FactoryBot.create(:priority, scheme: scheme1, name: 'P1', days: 1)
priority2 = FactoryBot.create(:priority, scheme: scheme1, name: 'P2', days: 3)
priority3 = FactoryBot.create(:priority, scheme: scheme1, name: 'P3', days: 5)
priority4 = FactoryBot.create(:priority, scheme: scheme1, name: 'P4', days: 30)

# Priorties
property1 = FactoryBot.create(
  :property, scheme: scheme1, address: '1 Hackney Street', postcode: 'N16NU'
)
property2 = FactoryBot.create(
  :property, scheme: scheme1, address: '2 Hackney Street', postcode: 'N16NU'
)
property3 = FactoryBot.create(
  :property, scheme: scheme1, address: '3 Hackney Street', postcode: 'N16NP'
)
property4 = FactoryBot.create(
  :property, scheme: scheme1, address: '4 Hackney Street', postcode: 'N16NP'
)

[property1, property2, property3, property4].each do |property|
  FactoryBot.create_list(
    :defect,
    10,
    :with_comments,
    property: property,
    priority: [priority1, priority2, priority3, priority4].sample
  )
end
