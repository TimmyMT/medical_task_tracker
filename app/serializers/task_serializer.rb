class TaskSerializer < ActiveModel::Serializer
  attributes :id, :title, :description

  has_many :tags
  has_one :recurrence_rule

  attribute :occurrences do
    options[:occurrences] || []
  end
end
