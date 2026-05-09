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

    preload_occurrences!

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

  attr_reader :task, :rule, :from, :to, :existing_occurrences

  def preload_occurrences!
    @existing_occurrences =
      TaskOccurrence
        .where(task: task, date: from..to)
        .index_by(&:date)
  end

  def generate_daily
    step = rule.interval || 1

    (from..to).each_with_index.map do |date, index|
      next unless (index % step).zero?

      build_occurrence(date)
    end.compact
  end

  def generate_monthly
    days = rule.days_of_month || []

    (from..to).select do |date|
      days.include?(date.day)
    end.map do |date|
      build_occurrence(date)
    end
  end

  def generate_specific_dates
    (rule.specific_dates || [])
      .select { |date| date >= from && date <= to }
      .map { |date| build_occurrence(date) }
  end

  def generate_odd_even
    (from..to).select do |date|
      rule.odd? ? date.day.odd? : date.day.even?
    end.map do |date|
      build_occurrence(date)
    end
  end

  def build_occurrence(date)
    existing = existing_occurrences[date]

    return existing if existing

    TaskOccurrence.new(
      task: task,
      date: date,
      status: :pending
    )
  end
end
