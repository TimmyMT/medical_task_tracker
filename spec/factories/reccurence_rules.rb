FactoryBot.define do
  factory :recurrence_rule do
    rule_type { :daily }
    interval { 1 }
  end
end
