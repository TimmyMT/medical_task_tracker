class Task < ApplicationRecord
  belongs_to :recurrence_rule, optional: true

  validates :title, presence: true
end
