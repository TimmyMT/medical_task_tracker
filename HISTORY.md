# HISTORY (LLM usage log)

During development of this project, LLM was used as an architectural assistant to clarify system design decisions and explore different implementation approaches.

---

## 1. Architecture of recurring tasks system

**User:**
Я делаю систему задач с повторениями (ежедневные, ежемесячные, по датам и т.д.).  
Я не понимаю как правильно хранить такие задачи в БД.  
Если создавать записи заранее — получится миллионы строк.  
Как обычно решают такую проблему в реальных системах?

**LLM:**
В таких системах обычно используют не генерацию всех задач заранее, а модель "rule + runtime generation".

Подход:
- Task хранит шаблон задачи
- RecurrenceRule хранит правило повторения
- TaskOccurrence хранит только исключения и фактическое состояние

А сами "выпадения" задач генерируются динамически в заданном диапазоне дат (например, from/to).

Это решает проблему бесконечности данных и масштабируемости.

---

## 2. Independent state of occurrences

**User:**
Если задача повторяется ежедневно, но пользователь отметил выполнение только за сегодня — как не сломать остальные дни?

**LLM:**
Для этого вводится сущность TaskOccurrence.

Каждое "выпадение" задачи на конкретную дату имеет:
- свою дату
- свой статус (pending/completed/skipped)

Таким образом:
- шаблон задачи не изменяется
- изменяется только конкретный экземпляр

---

## 3. Performance concern in recurrence engine

**User:**
Я реализовал генерацию повторений через перебор дат и поиск TaskOccurrence через find_by.  
Это нормально или будет проблема с производительностью?

**LLM:**
Использование find_by внутри цикла создаёт проблему N+1 queries.

Лучшее решение:
- заранее загрузить все TaskOccurrence за диапазон дат
- использовать index_by(&:date) для O(1) доступа

Это уменьшает количество запросов до одного.

---

## 4. System design decision: no persistence of occurrences

**User:**
Почему нельзя просто сохранять все TaskOccurrence заранее в базе?

**LLM:**
Проблема в бесконечных правилах (например, daily forever).

Если заранее создавать записи:
- база будет бесконечно расти
- появятся проблемы с хранением и индексацией

Поэтому используется lazy evaluation:
- данные генерируются только при запросе
- в пределах нужного диапазона дат

---

## 5. Tags and system constraints

**User:**
У меня есть системные теги, которые нельзя удалять или редактировать.  
Где лучше реализовать эту логику?

**LLM:**
Такая бизнес-логика должна находиться в модели Tag, а не в контроллере.

Используются callbacks:
- before_destroy
- before_update

Это гарантирует защиту данных независимо от точки входа (API, console, seeds).

## 6. Service object design for recurrence logic

**User:**
Я хочу вынести логику генерации повторяющихся задач в сервисный объект.  
Как правильно структурировать такой сервис в Rails?  
И где должна жить логика: в модели или в сервисе?

**LLM:**
В данном случае лучше использовать service object, потому что:
- логика генерации не относится напрямую к модели Task
- есть сложные правила (daily, monthly, specific dates, odd/even)
- требуется работа с диапазоном дат

Рекомендуется создать отдельный сервис:

```
app/services/tasks/recurrence_engine.rb
```

Он должен:
- принимать task и диапазон дат (from/to)
- учитывать RecurrenceRule
- генерировать виртуальные occurrences
- не сохранять данные в БД (только вычисление)

---

**LLM (предложенное решение):**

```ruby
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
    end.map { |date| build_occurrence(date) }
  end

  def generate_specific_dates
    (rule.specific_dates || [])
      .select { |date| date >= from && date <= to }
      .map { |date| build_occurrence(date) }
  end

  def generate_odd_even
    (from..to).select do |date|
      rule.odd? ? date.day.odd? : date.day.even?
    end.map { |date| build_occurrence(date) }
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
```

---

**LLM:**
Такой подход соответствует:
- Service Object pattern
- Single Responsibility Principle
- Clean separation between domain model and business logic

Также важно, что сервис:
- не сохраняет данные в БД
- работает только с вычислением состояния
- легко тестируется отдельно от моделей
