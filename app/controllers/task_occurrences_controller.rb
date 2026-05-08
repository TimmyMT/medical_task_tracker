class TaskOccurrencesController < ApplicationController
  def update
    occurrence = TaskOccurrence.find(params[:id])

    if occurrence.update(task_occurrence_params)
      render json: occurrence
    else
      render json: { errors: occurrence.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def task_occurrence_params
    params.require(:task_occurrence).permit(:status)
  end
end
