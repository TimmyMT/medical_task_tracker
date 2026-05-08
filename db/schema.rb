# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_05_08_162945) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "recurrence_rules", force: :cascade do |t|
    t.integer "rule_type", null: false
    t.integer "interval"
    t.integer "odd_even_type"
    t.integer "days_of_month", default: [], array: true
    t.date "specific_dates", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "system", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "task_occurrences", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.date "date", null: false
    t.integer "status", default: 0, null: false
    t.boolean "overridden", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["task_id", "date"], name: "index_task_occurrences_on_task_id_and_date", unique: true
    t.index ["task_id"], name: "index_task_occurrences_on_task_id"
  end

  create_table "task_tags", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id"], name: "index_task_tags_on_tag_id"
    t.index ["task_id", "tag_id"], name: "index_task_tags_on_task_id_and_tag_id", unique: true
    t.index ["task_id"], name: "index_task_tags_on_task_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "recurrence_rule_id"
    t.index ["recurrence_rule_id"], name: "index_tasks_on_recurrence_rule_id"
  end

  add_foreign_key "task_occurrences", "tasks"
  add_foreign_key "task_tags", "tags"
  add_foreign_key "task_tags", "tasks"
  add_foreign_key "tasks", "recurrence_rules"
end
