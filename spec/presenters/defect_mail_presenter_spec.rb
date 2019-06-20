require 'rails_helper'

RSpec.describe DefectMailPresenter do
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
    it 'returns the created at timestamp' do
      result = described_class.new(property_defect).created_at
      expect(result).to eq(property_defect.created_at)
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
        expect(result).to eq(communal_defect.access_information)
      end
    end
  end

  describe '#location' do
    it 'returns the location' do
      result = described_class.new(property_defect).location
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

  describe '#target_completion_date' do
    it 'returns the targetted completion date' do
      result = described_class.new(property_defect).target_completion_date
      expect(result).to eq(property_defect.target_completion_date)
    end
  end
end
