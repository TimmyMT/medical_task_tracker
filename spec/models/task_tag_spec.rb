require 'rails_helper'

RSpec.describe TaskTag, type: :model do
  describe 'validations' do
    it 'is valid with task and tag' do
      task = create(:task)
      tag = create(:tag)

      task_tag = build(:task_tag, task: task, tag: tag)

      expect(task_tag).to be_valid
    end

    it 'prevents duplicate task-tag pairs' do
      task = create(:task)
      tag = create(:tag)

      create(:task_tag, task: task, tag: tag)

      duplicate = build(:task_tag, task: task, tag: tag)

      expect(duplicate).not_to be_valid
    end
  end
end
