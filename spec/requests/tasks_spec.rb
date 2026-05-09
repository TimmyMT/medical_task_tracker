require 'swagger_helper'

RSpec.describe 'Tasks API', type: :request do
  path '/tasks' do
    get 'List tasks with recurrence' do
      tags 'Tasks'
      produces 'application/json'

      parameter name: :from, in: :query, type: :string, required: false
      parameter name: :to, in: :query, type: :string, required: false
      parameter name: :tag_ids, in: :query, type: :array, required: false, items: { type: :integer }

      response '200', 'tasks found' do
        let!(:task) { create(:task, title: 'Test task') }

        let(:from) { '2026-05-01' }
        let(:to)   { '2026-05-07' }

        run_test! do |response|
          json = JSON.parse(response.body)['tasks']

          expect(response.status).to eq(200)
          expect(json).to be_an(Array)

          expect(json.first['title']).to eq('Test task')
          expect(json.first).to have_key('id')
        end
      end
    end

    post 'Create task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              recurrence_rule_id: { type: :integer }
            },
            required: ['title']
          }
        }
      }

      response '201', 'task created' do
        let(:task) do
          {
            task: {
              title: 'New task',
              description: 'Some text'
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)['task']

          expect(response.status).to eq(201)
          expect(json['title']).to eq('New task')
          expect(json).to have_key('id')
        end
      end
    end
  end

  path '/tasks/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Show task' do
      tags 'Tasks'
      produces 'application/json'

      response '200', 'task found' do
        let(:task_record) { create(:task, title: 'Show task') }
        let(:id) { task_record.id }

        run_test! do |response|
          json = JSON.parse(response.body)['task']

          expect(response.status).to eq(200)
          expect(json['id']).to eq(task_record.id)
          expect(json['title']).to eq('Show task')
        end
      end
    end

    patch 'Update task' do
      tags 'Tasks'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :task, in: :body, schema: {
        type: :object,
        properties: {
          task: {
            type: :object,
            properties: {
              title: { type: :string }
            }
          }
        }
      }

      response '200', 'task updated' do
        let(:task_record) { create(:task, title: 'Old title') }
        let(:id) { task_record.id }

        let(:task) do
          {
            task: {
              title: 'Updated title'
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)['task']

          expect(response.status).to eq(200)
          expect(json['title']).to eq('Updated title')
        end
      end

      response '200', 'added tag' do
        let(:task_record) { create(:task, title: 'Old title') }
        let(:id) { task_record.id }
        let!(:tag) { create(:tag, name: 'операции') }

        let(:task) do
          {
            task: {
              tag_ids: [tag.id]
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)['task']

          expect(response.status).to eq(200)
          expect(json['tags']).not_to be_empty
          expect(json['tags'].first['id']).to eq(tag.id)
        end
      end

      response '200', 'delete tag' do
        let(:task_record) { create(:task, title: 'Old title') }
        let(:id) { task_record.id }

        let(:task) do
          {
            task: {
              tag_ids: []
            }
          }
        end

        run_test! do |response|
          json = JSON.parse(response.body)['task']

          expect(response.status).to eq(200)
          expect(json['tags']).to be_empty
        end
      end
    end

    delete 'Delete task' do
      tags 'Tasks'

      response '204', 'task deleted' do
        let(:task_record) { create(:task) }
        let(:id) { task_record.id }

        run_test! do |response|
          expect(response.status).to eq(204)
          expect(response.body).to be_empty
        end
      end
    end
  end
end
