class AddRecurrenceRuleToTasks < ActiveRecord::Migration[7.1]
  def change
    add_reference :tasks, :recurrence_rule, foreign_key: true
  end
end
