# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

puts 'Creating system tags...'

[
  'отчетность',
  'операции',
  'звонок'
].each do |name|
  Tag.find_or_create_by!(name: name) do |tag|
    tag.system = true
  end
end

puts 'Creating recurrence rules...'

daily_rule = RecurrenceRule.find_or_create_by!(
  rule_type: :daily,
  interval: 1
)

monthly_rule = RecurrenceRule.find_or_create_by!(
  rule_type: :monthly,
  days_of_month: [1, 15]
)

specific_dates_rule = RecurrenceRule.find_or_create_by!(
  rule_type: :specific_dates,
  specific_dates: [
    Date.new(2026, 5, 10),
    Date.new(2026, 5, 20)
  ]
)

odd_days_rule = RecurrenceRule.find_or_create_by!(
  rule_type: :odd_even,
  odd_even_type: :odd
)

even_days_rule = RecurrenceRule.find_or_create_by!(
  rule_type: :odd_even,
  odd_even_type: :even
)

puts 'Creating demo tasks...'

task = Task.find_or_create_by!(title: 'Ежедневный обход') do |t|
  t.description = 'Проверить пациентов'
  t.recurrence_rule = daily_rule
end

task.tags << Tag.find_by(name: 'операции')

puts 'Seeds completed!'
