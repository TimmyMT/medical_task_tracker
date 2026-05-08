require 'rails_helper'

RSpec.describe Tasks::RecurrenceEngine do
  let(:task) { create(:task, recurrence_rule: rule) }
  let(:from) { Date.new(2026, 5, 1) }
  let(:to)   { Date.new(2026, 5, 5) }

  let(:service) do
    described_class.new(task: task, from: from, to: to)
  end

  let(:result_dates) do
    service.call.map(&:date)
  end

  describe '#call' do
    context 'when rule is daily' do
      let(:rule) do
        create(:recurrence_rule, rule_type: :daily, interval: 1)
      end

      it 'generates daily occurrences' do
        expect(result_dates).to eq([
                                     Date.new(2026, 5, 1),
                                     Date.new(2026, 5, 2),
                                     Date.new(2026, 5, 3),
                                     Date.new(2026, 5, 4),
                                     Date.new(2026, 5, 5)
                                   ])
      end
    end

    context 'when rule is monthly' do
      let(:rule) do
        create(:recurrence_rule,
               rule_type: :monthly,
               days_of_month: [1, 3])
      end

      it 'generates occurrences only for selected days' do
        expect(result_dates).to eq([
                                     Date.new(2026, 5, 1),
                                     Date.new(2026, 5, 3)
                                   ])
      end
    end

    context 'when rule is specific dates' do
      let(:rule) do
        create(:recurrence_rule,
               rule_type: :specific_dates,
               specific_dates: [
                 Date.new(2026, 5, 1),
                 Date.new(2026, 5, 10)
               ])
      end

      it 'returns only dates inside range' do
        expect(result_dates).to eq([
                                     Date.new(2026, 5, 1)
                                   ])
      end
    end

    context 'when rule is odd days' do
      let(:rule) do
        create(:recurrence_rule,
               rule_type: :odd_even,
               odd_even_type: :odd)
      end

      it 'generates only odd days' do
        expect(result_dates).to eq([
                                     Date.new(2026, 5, 1),
                                     Date.new(2026, 5, 3),
                                     Date.new(2026, 5, 5)
                                   ])
      end
    end

    context 'when rule is missing' do
      let(:task) { create(:task, recurrence_rule: nil) }

      it 'returns empty array' do
        expect(service.call).to eq([])
      end
    end
  end
end
