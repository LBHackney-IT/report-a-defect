require 'rails_helper'

RSpec.describe CombinedReportPresenter do
  let(:schemes) { create_list(:scheme, 2, start_date: 1.day.ago) }
  let(:property) { create(:property, scheme: schemes.first) }
  let(:priority) { create(:priority, scheme: schemes.first) }

  describe '#defects' do
    it 'returns all defects for the schemes' do
      defect = create(:property_defect, property: property, priority: priority)
      result = described_class.new(schemes: schemes).defects
      expect(result).to include(defect)
    end

    context 'a ReportForm is injected with a date range' do
      it 'returns on defects created within that range' do
        from_date = Date.new(2019, 1, 1)
        to_date = Date.new(2019, 12, 1)
        date_range = from_date..to_date
        report_form = double(from_date: from_date, to_date: to_date, date_range: date_range)

        before_range_defect = create(:property_defect, added_at: Time.utc(2018, 1, 1), property: property, priority: priority)
        in_range_defect = create(:property_defect, added_at: Time.utc(2019, 2, 1), property: property, priority: priority)
        after_range_defect = create(:property_defect, added_at: Time.utc(2020, 1, 1), property: property, priority: priority)

        result = described_class.new(schemes: schemes, report_form: report_form).defects

        expect(result).to include(in_range_defect)
        expect(result).not_to include(before_range_defect)
        expect(result).not_to include(after_range_defect)
      end
    end
  end

  describe '#date_range' do
    it 'returns a time range for all the data being viewed in a string format' do
      travel_to Time.zone.parse('2019-07-16')

      from_date = Date.new(2019, 1, 10)
      to_date = Date.current

      report_form = double(from_date: from_date, to_date: to_date)
      result = described_class.new(schemes: schemes, report_form: report_form).date_range
      expect(result).to eq('From 10 January 2019 to 16 July 2019')

      travel_back
    end
  end

  describe '#defects_by_status' do
    it 'returns all defects with the given status' do
      outstanding_defect = create(:property_defect, property: property, priority: priority, status: :outstanding)
      closed_defect = create(:property_defect, property: property, priority: priority, status: :closed)

      result = described_class.new(schemes: schemes).defects_by_status(text: 'outstanding')
      expect(result).to include(outstanding_defect)
      expect(result).not_to include(closed_defect)
    end

    context 'when the status is closed' do
      it 'does not return an inflated number' do
        create(:property_defect, property: property, priority: priority, status: :outstanding)
        create(:property_defect, property: property, priority: priority, status: :completed)
        create(:property_defect, property: property, priority: priority, status: :closed)
        create(:property_defect, property: property, priority: priority, status: :closed)
        result = described_class.new(schemes: schemes).defects_by_status(text: 'closed')
        expect(result.count).to eql(2)
      end
    end
  end

  describe '#defects_by_category' do
    it 'returns a count for all defects where the trade matches the category' do
      electrical_defect = create(:property_defect, property: property, trade: 'Electrical')
      plumbing_defect = create(:property_defect, property: property, trade: 'Drainage')

      result = described_class.new(schemes: schemes).defects_by_category(category: 'Plumbing')

      expect(result).to include(plumbing_defect)
      expect(result).not_to include(electrical_defect)
    end
  end

  describe '#category_percentage' do
    it 'returns the percentage of defects with this category ' do
      create(:property_defect, property: property, trade: 'Plumbing')
      create(:property_defect, property: property, trade: 'Electrical')
      result = described_class.new(schemes: schemes).category_percentage(category: 'Electrical/Mechanical')
      expect(result).to eql('50.0%')
    end

    context 'when there the total defect count is odd' do
      it 'returns a rounded percentage%' do
        create(:property_defect, property: property, trade: 'Electrical')
        create(:property_defect, property: property, trade: 'Plumbing')
        create(:property_defect, property: property, trade: 'Plumbing')
        result = described_class.new(schemes: schemes).category_percentage(category: 'Electrical/Mechanical')
        expect(result).to eql('33.33%')
      end
    end

    context 'when there are no defects with that trade' do
      it 'returns 0.0%' do
        result = described_class.new(schemes: schemes).category_percentage(category: 'Electrical/Mechanical')
        expect(result).to eql('0.0%')
      end
    end
  end

  describe '#defects_by_priority' do
    let(:second_priority) { create(:priority, scheme: schemes.last) }

    it 'returns a count for all defects for the given priority' do
      first_priority_defect = create(:property_defect, property: property, priority: priority)
      second_priority_defect = create(:property_defect, property: property, priority: second_priority)

      result = described_class.new(schemes: [schemes.first]).defects_by_priority(priority: priority.name)

      expect(result).to include(first_priority_defect)
      expect(result).not_to include(second_priority_defect)
    end
  end

  describe '#priority_percentage' do
    it 'returns the percentage of defects completed on time with this priority ' do
      travel_to Time.zone.parse('2019-05-23')

      _completed_on_time_priority = create(:property_defect,
                                           property: property,
                                           priority: priority,
                                           target_completion_date: Date.new(2019, 5, 24),
                                           actual_completion_date: Date.new(2019, 5, 23),
                                           status: :completed)

      _completed_late_priority = create(
        :property_defect,
        property: property,
        priority: priority,
        target_completion_date: Date.new(2019, 5, 24),
        actual_completion_date: Date.new(2019, 5, 25),
        status: :completed
      )

      _still_overdue_priority = create(
        :property_defect,
        property: property,
        priority: priority,
        target_completion_date: Date.new(2019, 5, 22),
        status: :outstanding
      )

      result = described_class.new(schemes: schemes).priority_percentage(priority: priority.name)
      expect(result).to eql('33.33%')

      travel_back
    end

    context 'when there are no defects with that priority' do
      it 'returns 0.0%' do
        result = described_class.new(schemes: schemes).priority_percentage(priority: priority)
        expect(result).to eql('0.0%')
      end
    end
  end

  describe '#due_defects_by_priority' do
    it 'returns all open defects with a target_completion_date before todays date' do
      travel_to Time.zone.parse('2019-05-23')

      due_tomorrow_priority_defect = create(:property_defect,
                                            property: property,
                                            priority: priority,
                                            status: 'outstanding',
                                            target_completion_date: Date.new(2019, 5, 24))
      due_today_priority_defect = create(:property_defect,
                                         property: property,
                                         priority: priority,
                                         status: 'outstanding',
                                         target_completion_date: Date.new(2019, 5, 23))
      completed_priority_defect = create(:property_defect,
                                         property: property,
                                         priority: priority,
                                         status: 'completed',
                                         target_completion_date: Date.new(2019, 5, 24))
      overdue_priority_defect = create(:property_defect,
                                       property: property,
                                       priority: priority,
                                       status: 'outstanding',
                                       target_completion_date: Date.new(2019, 5, 22))

      result = described_class.new(schemes: schemes).due_defects_by_priority(priority: priority.name)

      expect(result).to include(due_tomorrow_priority_defect)
      expect(result).to include(due_today_priority_defect)
      expect(result).not_to include(completed_priority_defect)
      expect(result).not_to include(overdue_priority_defect)

      travel_back
    end
  end

  describe '#overdue_defects_by_priority' do
    it 'returns all defects completed late, or with a target_completion_date before today\'s date, or completed with no actual_completion_date' do
      travel_to Time.zone.parse('2019-05-23')

      due_tomorrow_priority_defect = create(:property_defect,
                                            property: property,
                                            priority: priority,
                                            status: 'outstanding',
                                            target_completion_date: Date.new(2019, 5, 24))
      due_today_priority_defect = create(:property_defect,
                                         property: property,
                                         priority: priority,
                                         status: 'outstanding',
                                         target_completion_date: Date.new(2019, 5, 23))
      priority_defect_completed_on_time = create(:property_defect,
                                                 property: property,
                                                 priority: priority,
                                                 status: 'completed',
                                                 target_completion_date: Date.new(2019, 5, 22),
                                                 actual_completion_date: Date.new(2019, 5, 21))
      overdue_priority_defect = create(:property_defect,
                                       property: property,
                                       priority: priority,
                                       status: 'outstanding',
                                       target_completion_date: Date.new(2019, 5, 22))
      late_completed_priority_defect = create(:property_defect,
                                              property: property,
                                              priority: priority,
                                              status: 'outstanding',
                                              target_completion_date: Date.new(2019, 5, 22),
                                              actual_completion_date: Date.new(2019, 5, 23))
      completed_with_no_actual_completion_date_defect = create(:property_defect,
                                                               property: property,
                                                               priority: priority,
                                                               status: 'completed',
                                                               target_completion_date: Date.new(2019, 5, 22))

      result = described_class.new(schemes: schemes).overdue_defects_by_priority(priority: priority.name)

      expect(result).not_to include(due_tomorrow_priority_defect)
      expect(result).not_to include(due_today_priority_defect)
      expect(result).not_to include(priority_defect_completed_on_time)
      expect(result).to include(overdue_priority_defect)
      expect(result).to include(late_completed_priority_defect)
      expect(result).to include(completed_with_no_actual_completion_date_defect)

      travel_back
    end
  end

  describe '#defects_completed_on_time' do
    it 'returns a count for all defects closed before or on their target date' do
      travel_to Time.zone.local(2019, 5, 21, 10, 0, 0)
      completed_early_defect = create(:property_defect,
                                      status: :completed,
                                      property: property,
                                      priority: priority,
                                      target_completion_date: Date.new(2019, 5, 23),
                                      actual_completion_date: Date.new(2019, 5, 22))
      closed_on_time_defect = create(:property_defect,
                                     status: :closed,
                                     property: property,
                                     priority: priority,
                                     target_completion_date: Date.new(2019, 5, 23),
                                     actual_completion_date: Date.new(2019, 5, 23))
      rejected_on_time_defect = create(:property_defect,
                                       status: :rejected,
                                       property: property,
                                       priority: priority,
                                       target_completion_date: Date.new(2019, 5, 23),
                                       actual_completion_date: Date.new(2019, 5, 23))
      completed_later_defect = create(:property_defect,
                                      status: :completed,
                                      property: property,
                                      priority: priority,
                                      target_completion_date: Date.new(2019, 5, 23),
                                      actual_completion_date: Date.new(2019, 5, 25)),
                               completed_defect_no_actual_completion_date = create(:property_defect,
                                                                                   status: :completed,
                                                                                   property: property,
                                                                                   priority: priority,
                                                                                   target_completion_date: Date.new(2019, 5, 23))

      travel_to Time.zone.local(2019, 5, 23, 10, 20, 10)

      result = described_class.new(schemes: schemes).defects_completed_on_time(priority: priority.name)

      expect(result).to include(completed_early_defect)
      expect(result).to include(closed_on_time_defect)
      expect(result).to include(rejected_on_time_defect)
      expect(result).not_to include(completed_later_defect)
      expect(result).not_to include(completed_defect_no_actual_completion_date)

      travel_back
    end

    context 'when the defect has flipped back from completed to in progress' do
      it 'does not include that defect in the count' do
        completed_on_time_defect = create(:property_defect,
                                          property: property,
                                          priority: priority,
                                          target_completion_date: Date.new(2019, 5, 23))

        completed_on_time_defect.completed!
        completed_on_time_defect.outstanding!

        result = described_class.new(schemes: schemes).defects_completed_on_time(priority: priority)

        expect(result).not_to include(completed_on_time_defect)
      end
    end
  end

  describe '#priorities_with_defects' do
    context 'when one priority has no defects' do
      it 'ignores that priority' do
        p1 = create(:priority, name: 'P1', scheme: property.scheme)
        p2 = create(:priority, name: 'P2', scheme: property.scheme)
        _defect = create(:property_defect, property: property, priority: p1)

        result = described_class.new(schemes: schemes).priorities_with_defects

        expect(result).to include(p1.name)
        expect(result).not_to include(p2.name)
      end
    end
  end
end
