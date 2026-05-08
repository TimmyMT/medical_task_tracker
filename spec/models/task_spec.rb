require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'validations' do
    it 'is valid with a title' do
      task = build(:task, title: 'Test task', description: 'Some text')

      expect(task).to be_valid
    end

    it 'is invalid without a title' do
      task = build(:task, title: nil, description: 'Some text')

      expect(task).not_to be_valid
      expect(task.errors[:title]).not_to be_empty
    end
  end
end
