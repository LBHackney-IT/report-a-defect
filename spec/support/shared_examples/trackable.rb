RSpec.shared_examples 'a trackable resource' do |options|
  context "when creating a #{options[:resource]}" do
    let(:resource_key_string) { options[:resource].to_s.downcase }
    let(:resource_key_symbol) { resource_key_string.to_sym }
    let(:resource) { build(resource_key_symbol) }

    before(:each) do
      travel_to Time.zone.parse('2019-05-23')
    end

    after(:each) do
      travel_back
    end

    it 'creates a new activity record' do
      expect { resource.save }.to change { PublicActivity::Activity.count }.by_at_least(1)
    end

    it 'creates an activity record with an association to the created resource' do
      resource.save

      result = PublicActivity::Activity.find_by(trackable_id: resource.id, trackable_type: described_class.to_s)

      expect(result).to be_kind_of(PublicActivity::Activity)
      expect(result.trackable).to be_kind_of(described_class)
    end

    it 'creates an activity record with a key that identifies the event' do
      resource.save

      result = PublicActivity::Activity.find_by(trackable_id: resource.id, trackable_type: described_class.to_s)
      expect(result.key).to eq("#{resource_key_string}.create")
    end

    it 'creates an activity record with the creation date' do
      resource.save

      result = PublicActivity::Activity.find_by(trackable_id: resource.id, trackable_type: described_class.to_s)
      expect(result.created_at).to eq(Time.zone.now)
    end
  end

  context 'when updated'
end
