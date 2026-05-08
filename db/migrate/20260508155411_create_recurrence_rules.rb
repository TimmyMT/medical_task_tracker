class CreateRecurrenceRules < ActiveRecord::Migration[7.1]
  def change
    create_table :recurrence_rules do |t|
      t.integer :rule_type, null: false
      t.integer :interval
      t.integer :odd_even_type

      t.integer :days_of_month, array: true, default: []
      t.date :specific_dates, array: true, default: []

      t.timestamps
    end
  end
end
