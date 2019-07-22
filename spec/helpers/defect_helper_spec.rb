require 'rails_helper'

RSpec.describe DefectHelper, type: :helper do
  describe '#priority_form_label' do
    it 'returns a string that combines name and how many days in the future it will be' do
      travel_to Time.zone.parse('2019-05-23')

      priority = create(:priority, name: 'P1', days: 3)
      result = helper.priority_form_label(priority: priority)
      expect(result).to eq('P1 - 3 days from now')

      travel_back
    end

    context 'when the target completion date is tomorrow' do
      it 'returns the singular for days' do
        travel_to Time.zone.parse('2019-05-23')

        priority = create(:priority, name: 'P1', days: 1)
        result = helper.priority_form_label(priority: priority)
        expect(result).to eq('P1 - 1 day from now')

        travel_back
      end
    end
  end

  describe '#status_form_label' do
    it 'returns a capitalized string' do
      result = helper.status_form_label(option_array: ['outstanding', 0])
      expect(result).to eql('Outstanding')
    end

    it 'returns a string without underscores' do
      result = helper.status_form_label(option_array: ['end_of_year', 1])
      expect(result).to eql('End of year')
    end
  end

  describe '#view_path_for' do
    let(:property) { create(:property) }
    let(:communal_area) { create(:communal_area) }
    let(:defect) { create(:defect) }

    it 'returns a view path when the parent is a property' do
      result = helper.view_path_for(parent: property, defect: defect)
      expect(result).to eq(property_defect_path(property, defect))
    end

    it 'returns a view path when the parent is a communal_area' do
      result = helper.view_path_for(parent: communal_area, defect: defect)
      expect(result).to eq(communal_area_defect_path(communal_area, defect))
    end

    it 'returns nothing if the parent isn\'t expected' do
      result = helper.view_path_for(parent: double, defect: defect)
      expect(result).to eq(nil)
    end
  end

  describe '#defect_type_for' do
    it 'returns the string Property' do
      result = helper.defect_type_for(defect: build(:property_defect))
      expect(result).to eql('Property')
    end

    it 'returns the string Communal Area' do
      result = helper.defect_type_for(defect: build(:communal_defect))
      expect(result).to eql('Communal Area')
    end
  end

  describe '#event_description_for' do
    let(:defect) { create(:property_defect) }
    let(:user) { create(:user) }

    context 'when the key is defect.create' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.create')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.created',
                                     name: event.owner.name))
      end
    end

    context 'when the key is defect.update' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.update')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.updated',
                                     name: event.owner.name))
      end
    end

    context 'when the event describes a status change' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(
          trackable: defect,
          owner: user,
          key: 'defect.update',
          parameters: { changes: { status: %w[outstanding follow_on] } }
        )
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.status_changed',
                                     name: event.owner.name,
                                     old: 'Outstanding',
                                     new: 'Follow on'))
      end
    end

    context 'when the key is defect.forwarded_to_contractor' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.forwarded_to_contractor')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.forwarded_to_contractor',
                                     email: event.trackable.scheme.contractor_email_address))
      end
    end

    context 'when the key is forwarded_to_employer_agent' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.forwarded_to_employer_agent')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.forwarded_to_employer_agent',
                                     email: event.trackable.scheme.employer_agent_email_address))
      end
    end

    context 'when the key is defect.accepted' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.accepted')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.accepted',
                                     email: event.trackable.scheme.contractor_email_address))
      end
    end

    context 'when the key is defect.notification.contact.sent_to_contractor' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.notification.contact.sent_to_contractor')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.notification.contact.sent_to_contractor',
                                     phone_number: event.trackable.contact_phone_number))
      end
    end

    context 'when the key is defect.notification.contact.accepted_by_contractor' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.notification.contact.accepted_by_contractor')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.notification.contact.accepted_by_contractor',
                                     phone_number: event.trackable.contact_phone_number))
      end
    end

    context 'when the key is defect.notification.contact.completed' do
      it 'returns the event description' do
        event = PublicActivity::Activity.new(trackable: defect, owner: user, key: 'defect.notification.contact.completed')
        result = helper.event_description_for(event: event)
        expect(result).to eql(I18n.t('events.defect.notification.contact.completed',
                                     phone_number: event.trackable.contact_phone_number))
      end
    end
  end

  describe '#format_status' do
    it 'upcases the first word' do
      result = helper.format_status('outstanding')
      expect(result).to eql('Outstanding')
    end

    it 'replaces all underscores with empty spaces' do
      result = helper.format_status('raised_in_error')
      expect(result).to eql('Raised in error')
    end
  end
end
