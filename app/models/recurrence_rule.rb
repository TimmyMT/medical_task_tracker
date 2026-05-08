class RecurrenceRule < ApplicationRecord
  enum rule_type: {
    daily: 0,
    monthly: 1,
    specific_dates: 2,
    odd_even: 3
  }

  enum odd_even_type: {
    odd: 0,
    even: 1
  }

  validates :rule_type, presence: true
end
