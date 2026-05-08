class CreateTaskOccurrences < ActiveRecord::Migration[7.1]
  def change
    create_table :task_occurrences do |t|
      t.references :task, null: false, foreign_key: true

      t.date :date, null: false
      t.integer :status, null: false, default: 0

      t.boolean :overridden, default: false

      t.timestamps
    end

    add_index :task_occurrences, %i[task_id date], unique: true
  end
end
