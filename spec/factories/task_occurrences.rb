FactoryBot.define do
  factory :task_occurrence do
    association :task
    date { Date.today }
    status { :pending }
    overridden { false }
  end
end
