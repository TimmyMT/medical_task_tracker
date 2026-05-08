class TaskOccurrence < ApplicationRecord
  belongs_to :task

  enum status: {
    pending: 0,
    completed: 1,
    cancelled: 2
  }

  validates :date, presence: true

  scope :for_date_range, lambda { |from, to|
    where(date: from..to)
  }
end
