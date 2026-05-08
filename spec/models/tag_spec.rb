require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'validations' do
    it 'is valid with a name' do
      tag = build(:tag)
      expect(tag).to be_valid
    end

    it 'is invalid without a name' do
      tag = build(:tag, name: nil)
      expect(tag).not_to be_valid
    end
  end

  describe 'system protection' do
    it 'prevents deletion of system tags' do
      tag = create(:tag, system: true)

      expect(tag.destroy).to be_falsey
    end

    it 'prevents update of system tags' do
      tag = create(:tag, system: true, name: 'old')

      tag.update(name: 'new')

      expect(tag.errors[:base]).not_to be_empty
    end
  end
end
