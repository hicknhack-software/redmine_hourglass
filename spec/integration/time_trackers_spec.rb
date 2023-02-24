require_relative '../swagger_helper'

describe 'Time trackers API', type: :request do
  let(:key) { user.api_key }

  path '/time_trackers.json' do
    get 'Lists all visible running time trackers' do
      produces 'application/json'
      tags 'Time trackers'

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time, :hourglass_track_time

      response '200', 'time trackers found' do
        schema '$ref' => '#/definitions/index_response'

        let(:user) { create :user, :as_member, permissions: [:hourglass_view_tracked_time] }

        before do
          User.current = user
          @time_tracker = Hourglass::TimeTracker.start
          User.current = create :user
          @time_tracker2 = Hourglass::TimeTracker.start comments: 'test', project: create(:project), activity: create(:time_entry_activity)
        end

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:count]).to eq 2
          first, second = data[:records]
          if first[:id] != @time_tracker.id
            second, first = [first, second]
          end
          expect(Time.parse first[:start]).to eq @time_tracker.start
          expect(first[:user_id]).to eq @time_tracker.user_id
          expect(second[:comments]).to eq @time_tracker2.comments
          expect(second[:project_id]).to eq @time_tracker2.project_id
          expect(second[:activity_id]).to eq @time_tracker2.activity_id
        end
      end
    end
  end

  path '/time_trackers/start.json' do
    post 'Starts a new time tracker' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time trackers'
      parameter name: :time_tracker, in: :body, schema: {
          '$ref' => '#/definitions/time_tracker_start'
      }

      let(:time_tracker) { {time_tracker: {comments: 'test'}} }
      let(:user) { create :user, :as_member, permissions: [:hourglass_track_time] }

      include_examples 'access rights', :hourglass_track_time

      include_examples 'error message', 'time tracker not created', proc {
        User.current = user
        Hourglass::TimeTracker.start
      }

      response '200', 'time tracker created' do
        schema '$ref' => '#/definitions/time_tracker',
               required: %w(id start user_id created_at updated_at)

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:user_id]).to eq user.id
          expect(data[:comments]).to eq time_tracker[:time_tracker][:comments]
        end

        context 'with project id' do
          let(:time_tracker) { {time_tracker: {comments: 'test', project_id: user.projects.first.id}} }
          let(:user) { create :user, :as_member, permissions: [:hourglass_track_time, :hourglass_book_time] }

          it 'returns correct data' do
            data = JSON.parse(response.body, symbolize_names: true)
            expect(data[:user_id]).to eq user.id
            expect(data[:comments]).to eq time_tracker[:time_tracker][:comments]
            expect(data[:project_id]).to eq time_tracker[:time_tracker][:project_id]
          end
        end
      end
    end
  end

  path '/time_trackers/{id}.json' do
    get 'Find time tracker by ID' do
      produces 'application/json'
      tags 'Time trackers'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, :as_member, permissions: [:hourglass_view_tracked_time] }
      let(:time_tracker) do
        User.current = user
        Hourglass::TimeTracker.start comments: 'test'
      end
      let(:id) { time_tracker.id }

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time, :hourglass_track_time
      include_examples 'not found'

      response '200', 'time tracker found' do
        schema '$ref' => '#/definitions/time_tracker',
               required: %w(id start user_id created_at updated_at)

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:id]).to eq time_tracker.id
          expect(Time.parse data[:start]).to eq time_tracker.start
          expect(data[:user_id]).to eq time_tracker.user_id
          expect(data[:comments]).to eq time_tracker.comments
        end
      end
    end

    delete 'Deletes a time tracker' do
      tags 'Time trackers'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:time_tracker) do
        User.current = user
        Hourglass::TimeTracker.start
      end
      let(:id) { time_tracker.id }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time, success_code: '204'

      include_examples 'not found'

      response '204', 'time tracker deleted' do
        run_test!
      end
    end

    put 'Update an existing time tracker' do
      consumes 'application/json'
      tags 'Time trackers'
      parameter name: :id, in: :path, type: :string
      parameter name: :time_tracker, in: :body, schema: {
          '$ref' => '#/definitions/time_tracker_update'
      }

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:id) do
        User.current = user
        time_tracker = Hourglass::TimeTracker.start comments: 'test'
        time_tracker.id
      end
      let(:time_tracker) { {time_tracker: {comments: 'test2'}} }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time, success_code: '204'

      include_examples 'not found'

      response '204', 'time tracker found' do
        run_test!

        it 'changes the time tracker' do
          expect(Hourglass::TimeTracker.find_by(user: user).comments).to eq 'test2'
        end
      end

      include_examples 'error message', 'time tracker not updated', proc { |example|
        tt = Hourglass::TimeTracker.find id
        tt.issue_id = 10000
        tt.save validate: false
      }
    end
  end

  path '/time_trackers/{id}/stop.json' do
    # todo: test booking creation once start works better
    delete 'Stops a time tracker and create time records from it' do
      tags 'Time trackers'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, :as_member, permissions: [:hourglass_track_time, :hourglass_book_time] }
      let(:time_tracker) do
        User.current = user
        Hourglass::TimeTracker.start comments: 'test'
      end
      let(:id) { time_tracker.id }

      include_examples 'access rights', :hourglass_track_time

      include_examples 'not found'

      response '200', 'time log created' do
        schema type: 'object',
               properties: {
                   time_log: {
                       '$ref' => '#/definitions/time_log',
                       required: %w(id start stop user_id created_at updated_at)
                   },
                   time_booking: {
                       '$ref' => '#/definitions/time_booking',
                       required: %w(id user_id created_at updated_at)
                   }
               },
               required: %w(time_log)
        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:time_log][:user_id]).to eq user.id
          expect(data[:time_log][:comments]).to eq time_tracker.comments
          expect(Time.parse data[:time_log][:start]).to eq time_tracker.start
        end
      end

      include_examples 'error message', 'time tracker not stopped', proc { |example|
        Hourglass::TimeLog.create user: user, start: time_tracker.start, stop: Time.now.change(sec: 0) + 1.minute
      }
    end
  end

  path '/time_trackers/bulk_destroy.json' do
    delete 'Deletes multiple time trackers at once' do
      tags 'Time trackers'
      parameter name: :'time_trackers[]', in: :query, type: :array, items: {type: :string}, collectionFormat: :multi

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:time_tracker_ids) do
        User.current = user
        tt1 = Hourglass::TimeTracker.start comments: 'test'
        User.current = create :user
        tt2 = Hourglass::TimeTracker.start comments: 'test2'
        [tt1.id, tt2.id]
      end

      let(:'time_trackers[]') { time_tracker_ids }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time

      response '200', 'time trackers found' do
        run_test!
      end
    end
  end

  path '/time_trackers/bulk_update.json' do
    post 'Updates multiple time trackers at once' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time trackers'
      parameter name: :time_trackers, in: :body, schema: {type: :object, additionalProperties: {'$ref' => '#/definitions/time_tracker_update'}}, description: 'takes an object of time trackers'

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:time_tracker_ids) do
        User.current = user
        tt1 = Hourglass::TimeTracker.start comments: 'test'
        User.current = create :user
        tt2 = Hourglass::TimeTracker.start comments: 'test2'
        [tt1.id, tt2.id]
      end

      let(:'time_trackers') { {time_trackers: {time_tracker_ids[0] => {comments: 'test3'}, time_tracker_ids[1] => {comments: 'test4'}}} }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time

      response '200', 'time trackers found' do
        run_test!
      end
    end
  end
end
