class TaskOccurrenceSerializer < ActiveModel::Serializer
  attributes :id, :date, :status, :overridden
end
