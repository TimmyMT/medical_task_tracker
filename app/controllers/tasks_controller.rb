class TasksController < ApplicationController
  before_action :set_task, only: %i[show update destroy]

  def index
    tasks = Task.includes(:tags, :recurrence_rule)

    from = parse_date(params[:from], Date.today)
    to   = parse_date(params[:to], Date.today + 7)

    tasks = apply_tag_filter(tasks)

    render json: tasks.map { |task|
      occurrences = recurrence_for(task, from, to)

      TaskSerializer.new(
        task,
        { occurrences: occurrences }
      ).as_json
    }
  end

  def show
    from = parse_date(params[:from], Date.today)
    to   = parse_date(params[:to], Date.today + 7)

    occurrences = recurrence_for(@task, from, to)

    render json: TaskSerializer.new(
      @task,
      { occurrences: occurrences }
    )
  end

  def create
    task = Task.new(task_params)

    if task.save
      render json: TaskSerializer.new(task), status: :created
    else
      render json: { errors: task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params)
      render json: TaskSerializer.new(@task)
    else
      render json: { errors: @task.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    head :no_content
  end

  private

  def set_task
    @task = Task.find(params[:id])
  end

  def task_params
    params.require(:task).permit(:title, :description, :recurrence_rule_id, tag_ids: [])
  end

  def parse_date(value, default)
    value.present? ? Date.parse(value) : default
  end

  def recurrence_for(task, from, to)
    Tasks::RecurrenceEngine
      .new(task: task, from: from, to: to)
      .call
  end

  def apply_tag_filter(scope)
    return scope unless params[:tag_ids].present?

    scope.joins(:task_tags)
         .where(task_tags: { tag_id: params[:tag_ids] })
         .distinct
  end
end
