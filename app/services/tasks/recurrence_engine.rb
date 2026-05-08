# app/services/tasks/recurrence_engine.rb

class Tasks::RecurrenceEngine
  def initialize(task:, from:, to:)
    @task = task
    @rule = task.recurrence_rule
    @from = from
    @to = to
  end

  def call
    return [] unless rule

    case rule.rule_type.to_sym
    when :daily
      generate_daily
    when :monthly
      generate_monthly
    when :specific_dates
      generate_specific_dates
    when :odd_even
      generate_odd_even
    else
      []
    end
  end

  private

  attr_reader :task, :rule, :from, :to

  def generate_daily
    step = rule.interval || 1
    index = 0

    (from..to).map do |date|
      occurrence = build_occurrence(date) if index % step == 0
      index += 1
      occurrence
    end.compact
  end

  def generate_monthly
    days = rule.days_of_month || []

    (from..to).select do |date|
      days.include?(date.day)
    end.map { |date| build_occurrence(date) }
  end

  def generate_specific_dates
    (rule.specific_dates || [])
      .select { |date| date >= from && date <= to }
      .map { |date| build_occurrence(date) }
  end

  def generate_odd_even
    (from..to).select do |date|
      if rule.odd?
        date.day.odd?
      else
        date.day.even?
      end
    end.map { |date| build_occurrence(date) }
  end

  def build_occurrence(date)
    existing = TaskOccurrence.find_by(task: task, date: date)

    return existing if existing

    TaskOccurrence.new(
      task: task,
      date: date,
      status: :pending
    )
  end
end
