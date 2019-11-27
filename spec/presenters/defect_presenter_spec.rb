require 'rails_helper'

RSpec.describe DefectPresenter do
  let(:property_defect) do
    create(:property_defect)
  end

  describe '#reference_number' do
    it 'returns the reference number' do
      result = described_class.new(property_defect).reference_number
      expect(result).to eq(property_defect.reference_number)
    end
  end

  describe '#created_at' do
    it 'returns a formatted date' do
      defect = create(:property_defect)
      created_at = defect.created_at.to_date.to_s
      expect(described_class.new(defect).created_at).to eq(created_at)
    end
  end

  describe '#reporting_officer' do
    it 'returns a generic user name' do
      result = described_class.new(property_defect).reporting_officer
      expect(result).to eq('Hackney New Build team')
    end
  end

  describe '#address' do
    it 'returns the property address' do
      result = described_class.new(property_defect).address
      expect(result).to eq(property_defect.property.address)
    end

    context 'when it is a communal defect' do
      it 'returns the defects access information' do
        communal_defect = create(:communal_defect)
        result = described_class.new(communal_defect).address
        expect(result).to eq(communal_defect.communal_area.location)
      end
    end
  end

  describe '#defect_type' do
    it 'returns the location' do
      result = described_class.new(property_defect).defect_type
      expect(result).to eq('Property')
    end
  end

  describe '#contact_name' do
    it 'returns the contact name' do
      result = described_class.new(property_defect).contact_name
      expect(result).to eq(property_defect.contact_name)
    end
  end

  describe '#contact_phone_number' do
    it 'returns the contact phone number' do
      result = described_class.new(property_defect).contact_phone_number
      expect(result).to eq(property_defect.contact_phone_number)
    end
  end

  describe '#description' do
    it 'returns the description of the defect' do
      result = described_class.new(property_defect).description
      expect(result).to eq(property_defect.description)
    end
  end

  describe '#contractor_name' do
    it 'returns the contractor name' do
      result = described_class.new(property_defect).contractor_name
      expect(result).to eq(property_defect.scheme.contractor_name)
    end
  end

  describe '#contractor_email_address' do
    it 'returns the contractor email address' do
      result = described_class.new(property_defect).contractor_email_address
      expect(result).to eq(property_defect.scheme.contractor_email_address)
    end
  end

  describe '#priority_name' do
    it 'returns the name of the priority' do
      result = described_class.new(property_defect).priority_name
      expect(result).to eq(property_defect.priority.name)
    end
  end

  describe '#accepted_on' do
    before(:each) do
      travel_to Time.zone.parse('2019-05-23')
    end

    after(:each) do
      travel_back
    end

    context 'when the defect has been accepted' do
      it 'returns the time of acceptance' do
        defect = create(:property_defect)
        PublicActivity::Activity.create(trackable: defect, key: 'defect.accepted')
        expect(described_class.new(defect).accepted_on)
          .to eq('23rd May 2019, 00:00')
      end
    end

    context 'when the defect has NOT been accepted' do
      it 'returns an explanation' do
        defect = create(:property_defect)
        expect(described_class.new(defect).accepted_on)
          .to eq(I18n.t('page_content.defect.show.not_accepted_yet'))
      end
    end
  end

  describe '#target_completion_date' do
    it 'returns a formatted date' do
      defect = create(:property_defect)
      expected_date = defect.target_completion_date.to_s
      expect(described_class.new(defect).target_completion_date)
        .to eq(expected_date)
    end
  end

  describe '.to_row' do
    context 'when the defect is for a property' do
      it 'returns an array of values as they should appear in a CSV row' do
        defect = described_class.new(create(:property_defect, :completed))
        result = defect.to_row
        expect(result).to eq(
          [
            defect.reference_number,
            defect.created_at.to_s,
            defect.added_at.to_s,
            defect.title,
            'Property',
            defect.status,
            defect.trade,
            defect.category,
            defect.priority.name,
            defect.priority.days,
            defect.target_completion_date.to_s,
            defect.actual_completion_date.to_s,
            defect.scheme.estate.name,
            defect.scheme.name,
            defect.property.address,
            nil,
            nil,
            defect.description,
            defect.access_information,
            nil,
          ]
        )
      end
    end

    context 'when the defect is for a communal area' do
      it 'returns an array of values as they should appear in a CSV row' do
        defect = described_class.new(create(:communal_defect, :completed, flagged: true))
        result = defect.to_row
        expect(result).to eq(
          [
            defect.reference_number,
            defect.created_at.to_s,
            defect.added_at.to_s,
            defect.title,
            'Communal',
            defect.status,
            defect.trade,
            defect.category,
            defect.priority.name,
            defect.priority.days,
            defect.target_completion_date.to_s,
            defect.actual_completion_date.to_s,
            defect.scheme.estate.name,
            defect.scheme.name,
            nil,
            defect.communal_area.name,
            defect.communal_area.location,
            defect.description,
            defect.access_information,
            'flagged',
          ]
        )
      end
    end
  end

  describe '#category' do
    context 'when the trade belongs to the Plumbing category' do
      it 'returns "Plumbing"' do
        defect = create(:property_defect, trade: 'Drainage')
        result = described_class.new(defect).category
        expect(result).to eql('Plumbing')
      end

      context 'when the trade is the same as a category' do
        it 'returns "Plumbing"' do
          defect = create(:property_defect, trade: 'Plumbing')
          result = described_class.new(defect).category
          expect(result).to eql('Plumbing')
        end
      end
    end

    context 'when the trade belongs to the Electrical category' do
      it 'returns "Electrical/Mechanical"' do
        defect = create(:property_defect, trade: 'Lighting')
        result = described_class.new(defect).category
        expect(result).to eql('Electrical/Mechanical')
      end

      context 'when the trade is the same as a category' do
        it 'returns "Electrical/Mechanical"' do
          defect = create(:property_defect, trade: 'Electrical/Mechanical')
          result = described_class.new(defect).category
          expect(result).to eql('Electrical/Mechanical')
        end
      end
    end

    context 'when the trade belongs to the Carpentry category' do
      it 'returns "Carpentry/Doors"' do
        defect = create(:property_defect, trade: 'Door work')
        result = described_class.new(defect).category
        expect(result).to eql('Carpentry/Doors')
      end

      context 'when the trade is the same as a category' do
        it 'returns "Carpentry / Doors"' do
          defect = create(:property_defect, trade: 'Carpentry/Doors')
          result = described_class.new(defect).category
          expect(result).to eql('Carpentry/Doors')
        end
      end
    end

    context 'when the trade belongs to the Cosmetic category' do
      it 'returns "Cosmetic"' do
        defect = create(:property_defect, trade: 'Damp')
        result = described_class.new(defect).category
        expect(result).to eql('Cosmetic')
      end

      context 'when the trade is the same as a category' do
        it 'returns "Cosmetic"' do
          defect = create(:property_defect, trade: 'Cosmetic')
          result = described_class.new(defect).category
          expect(result).to eql('Cosmetic')
        end
      end
    end
  end
end
