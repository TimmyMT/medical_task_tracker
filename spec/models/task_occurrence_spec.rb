require 'rails_helper'

RSpec.describe TaskOccurrence, type: :model do
  describe 'validations' do
    it 'is valid with task, date and status' do
      task = create(:task)

      occurrence = build(:task_occurrence,
        task: task,
        date: Date.today,
        status: :pending
      )

      expect(occurrence).to be_valid
    end

    it 'is invalid without date' do
      task = create(:task)

      occurrence = build(:task_occurrence,
        task: task,
        date: nil,
        status: :pending
      )

      expect(occurrence).not_to be_valid
      expect(occurrence.errors[:date]).not_to be_empty
    end
  end

  describe 'associations' do
    it 'belongs to task' do
      assoc = described_class.reflect_on_association(:task)
      expect(assoc.macro).to eq(:belongs_to)
    end
  end

  describe 'enums' do
    it 'supports status transitions' do
      task = create(:task)

      occurrence = create(:task_occurrence,
        task: task,
        date: Date.today,
        status: :pending
      )

      expect(occurrence.pending?).to be true

      occurrence.completed!
      expect(occurrence.completed?).to be true
    end
  end

  describe 'scopes' do
    it 'filters occurrences by date range' do
      task = create(:task)

      occurrence1 = create(:task_occurrence,
        task: task,
        date: Date.new(2026, 5, 1)
      )

      occurrence2 = create(:task_occurrence,
        task: task,
        date: Date.new(2026, 5, 10)
      )

      occurrence3 = create(:task_occurrence,
        task: task,
        date: Date.new(2026, 6, 1)
      )

      result = TaskOccurrence.for_date_range(
        Date.new(2026, 5, 1),
        Date.new(2026, 5, 31)
      )

      expect(result).to include(occurrence1, occurrence2)
      expect(result).not_to include(occurrence3)
    end
  end
end
