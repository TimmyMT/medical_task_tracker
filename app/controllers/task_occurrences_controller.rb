class TaskOccurrencesController < ApplicationController
  def update
    occurrence = TaskOccurrence.find(params[:id])

    occurrence.update!(status: params[:status])

    render json: occurrence
  end
end
