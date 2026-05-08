require 'rails_helper'

RSpec.describe RecurrenceRule, type: :model do
  describe 'validations' do
    it 'is valid with a rule_type' do
      rule = build(:recurrence_rule, rule_type: :daily)

      expect(rule).to be_valid
    end

    it 'is invalid without a rule_type' do
      rule = build(:recurrence_rule, rule_type: nil)

      expect(rule).not_to be_valid
      expect(rule.errors[:rule_type]).not_to be_empty
    end
  end

  describe 'enums' do
    it 'defines rule types correctly' do
      rule = build(:recurrence_rule, rule_type: :monthly)

      expect(rule.monthly?).to be true
    end

    it 'defines odd/even types correctly' do
      rule = build(:recurrence_rule, rule_type: :odd_even, odd_even_type: :odd)

      expect(rule.odd?).to be true
    end
  end
end
