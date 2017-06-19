require 'swagger_helper'

describe 'Time logs API', type: :request do
  let(:key) { user.api_key }

  path '/time_logs.json' do
    get 'Lists all visible time logs' do
      produces 'application/json'
      tags 'Time logs'

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time

      response '200', 'time logs found' do
        schema type: 'array',
               items: {
                   '$ref': '#/definitions/time_log',
                   required: %w(id start stop user_id created_at updated_at)
               },
               title: 'Array'
        let(:user) { create :user, :as_member, permissions: [:hourglass_view_tracked_time] }

        before do
          @time_log = create :time_log, user: user
          @time_log2 = create :time_log_with_comments, user: create(:user)
        end

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data.length).to eq 2
          expect(data.first[:id]).to eq @time_log.id
          expect(Time.parse(data.first[:start])).to eq @time_log.start.change(sec: 0)
          expect(data.first[:user_id]).to eq @time_log.user_id
          expect(data.second[:comments]).to eq @time_log2.comments
        end
      end
    end
  end

  path '/time_logs/{id}.json' do
    get 'Find time log by ID' do
      produces 'application/json'
      tags 'Time logs'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, :as_member, permissions: [:hourglass_view_tracked_time] }
      let(:time_log) { create :time_log, user: user }
      let(:id) { time_log.id }

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time
      include_examples 'not found'

      response '200', 'time log found' do
        schema '$ref': '#/definitions/time_log',
               required: %w(id start stop user_id created_at updated_at)

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:id]).to eq time_log.id
          expect(Time.parse(data[:start])).to eq time_log.start.change(sec: 0)
          expect(Time.parse(data[:stop])).to eq time_log.stop.change(sec: 0)
          expect(data[:user_id]).to eq time_log.user_id
          expect(data[:comments]).to eq time_log.comments
        end
      end
    end

    delete 'Deletes a time log' do
      tags 'Time logs'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:time_log) { create :time_log, user: user }
      let(:id) { time_log.id }

      include_examples 'access rights', :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time, success_code: '204'

      include_examples 'not found'

      response '204', 'time log deleted' do
        run_test!
      end
    end

    put 'Update an existing time log' do
      consumes 'application/json'
      tags 'Time logs'
      parameter name: :id, in: :path, type: :string
      parameter name: :time_log, in: :body, schema: {
          '$ref': '#/definitions/time_log_update'
      }

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:id) do
        time_log = create :time_log, user: user
        time_log.id
      end
      let(:time_log) { {time_log: {comments: 'test2'}} }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time, success_code: '204'

      include_examples 'not found'
      context do
        let(:time_log) { {time_log: {stop: Time.now}} }
        response '204', 'time log found' do
          run_test!

          it 'changes the time log' do
            expect(Hourglass::TimeLog.find(id).stop).to eq time_log[:time_log][:stop].change(sec: 0)
          end
        end

        include_examples 'error message', 'time log not updated', proc { |example|
          tt = Hourglass::TimeLog.find id
          tt.comments = (0..300).map(&:to_s).join('')
          tt.save validate: false
        }
      end
    end
  end

  path '/time_logs/bulk_destroy.json' do
    delete 'Deletes multiple time logs at once' do
      tags 'Time logs'
      parameter name: :'time_logs[]', in: :query, type: :array, items: {type: :string}, collectionFormat: :multi

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:time_log_ids) do
        tt1 = create :time_log, user: user
        tt2 = create :time_log, user: create(:user)
        [tt1.id, tt2.id]
      end

      let(:'time_logs[]') { time_log_ids }

      include_examples 'access rights', :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time

      response '200', 'time logs found' do
        run_test!
      end
    end
  end

  path '/time_logs/bulk_update.json' do
    post 'Updates multiple time logs at once' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time logs'
      parameter name: :time_logs, in: :body, type: :object, additionalProperties: {'$ref': '#/definitions/time_log'}, description: 'takes an object of time logs'

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:time_log_ids) do
        tt1 = create :time_log_with_comments, user: user
        tt2 = create :time_log_with_comments, user: create(:user)
        [tt1.id, tt2.id]
      end

      let(:'time_logs') { {time_logs: {time_log_ids[0] => {comments: 'test3'}, time_log_ids[1] => {comments: 'test4'}}} }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time

      response '200', 'time logs found' do
        run_test!

        it 'changes the time logs' do
          expect(Hourglass::TimeLog.find(time_log_ids.first).comments).to eq 'test3'
          expect(Hourglass::TimeLog.find(time_log_ids.last).comments).to eq 'test4'
        end
      end
    end
  end
end
