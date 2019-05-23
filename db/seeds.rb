raise if Rails.env.production?

Estate.destroy_all
Scheme.destroy_all

# Estates
estate = FactoryBot.create(:estate, name: 'Kings Cresent')

# Schemes
scheme1 = FactoryBot.create(:scheme, estate: estate, name: '1')
FactoryBot.create(:scheme, estate: estate, name: '2')

# Priorties
FactoryBot.create(:priority, scheme: scheme1, name: 'P1', days: 1)
FactoryBot.create(:priority, scheme: scheme1, name: 'P2', days: 3)
FactoryBot.create(:priority, scheme: scheme1, name: 'P3', days: 5)
FactoryBot.create(:priority, scheme: scheme1, name: 'P4', days: 30)
