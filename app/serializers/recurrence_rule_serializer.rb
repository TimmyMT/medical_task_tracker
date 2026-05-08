class RecurrenceRuleSerializer < ActiveModel::Serializer
  attributes :rule_type, :interval, :odd_even_type
end
