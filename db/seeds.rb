puts 'Creating system tags...'

system_tags = [
  'отчетность',
  'операции',
  'звонок'
]

system_tags.each do |name|
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

daily_task = Task.find_or_create_by!(title: 'Ежедневный обход') do |task|
  task.description = 'Проверить пациентов'
  task.recurrence_rule = daily_rule
end

operations_tag = Tag.find_by!(name: 'операции')

unless daily_task.tags.exists?(operations_tag.id)
  daily_task.tags << operations_tag
end

puts 'Seeds completed!'
