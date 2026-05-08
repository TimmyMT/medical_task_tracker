class Task < ApplicationRecord
  belongs_to :recurrence_rule, optional: true

  has_many :task_tags, dependent: :destroy
  has_many :tags, through: :task_tags

  has_many :task_occurrences, dependent: :destroy

  validates :title, presence: true
end
