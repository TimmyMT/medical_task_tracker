require 'swagger_helper'

RSpec.describe 'TaskOccurrences API', type: :request do
  path '/task_occurrences/{id}' do
    patch 'Update task occurrence status' do
      tags 'TaskOccurrences'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer

      parameter name: :task_occurrence, in: :body, schema: {
        type: :object,
        properties: {
          status: {
            type: :string,
            enum: %w[pending completed cancelled]
          }
        },
        required: ['status']
      }

      response '200', 'task occurrence updated' do
        let(:task) { create(:task) }
        let(:occurrence) do
          create(
            :task_occurrence,
            task: task,
            status: :pending
          )
        end
        let(:id) { occurrence.id }
        let(:task_occurrence) do
          {
            task_occurrence: {
              status: 'completed'
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)["task_occurrence"]

          expect(response.status).to eq(200)

          expect(json['id']).to eq(occurrence.id)
          expect(json['status']).to eq('completed')

          expect(occurrence.reload.completed?).to be true
        end
      end
    end
  end
end
