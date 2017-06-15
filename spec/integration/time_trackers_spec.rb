require 'swagger_helper'

describe 'Time trackers API', type: :request do
  let(:key) { user.api_key }

  path '/time_trackers.json' do
    get 'Lists all visible running time trackers' do
      produces 'application/json'
      tags 'Time trackers'

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time

      response '200', 'time trackers found' do
        schema type: 'array',
               items: {
                   '$ref': '#/definitions/time_tracker',
                   required: %w(id start user_id created_at updated_at)
               },
               title: 'Array'
        let(:user) { create :user, :as_member, permissions: [:hourglass_view_tracked_time] }

        before do
          User.current = user
          @time_tracker = Hourglass::TimeTracker.start
          User.current = create(:user, :as_member, permissions: [:hourglass_view_tracked_time])
          @time_tracker2 = Hourglass::TimeTracker.start comments: 'test', project: create(:project), activity: create(:time_entry_activity)
        end

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data.length).to eq 2
          expect(data.first[:id]).to eq @time_tracker.id
          expect(Time.parse data.first[:start]).to eq @time_tracker.start
          expect(data.first[:user_id]).to eq @time_tracker.user_id
          expect(data.second[:comments]).to eq @time_tracker2.comments
          expect(data.second[:project_id]).to eq @time_tracker2.project_id
          expect(data.second[:activity_id]).to eq @time_tracker2.activity_id
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
          '$ref': '#/definitions/time_tracker_start'
      }

      let(:time_tracker) { {time_tracker: {comments: 'test'}} }
      let(:user) { create :user, :as_member, permissions: [:hourglass_track_time] }

      include_examples 'access rights', :hourglass_track_time

      include_examples 'error message', 'time tracker not created', proc {
        User.current = user
        Hourglass::TimeTracker.start
      }

      response '200', 'time tracker created' do
        schema '$ref': '#/definitions/time_tracker',
               required: %w(id start user_id created_at updated_at)

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:user_id]).to eq user.id
          expect(data[:comments]).to eq time_tracker[:time_tracker][:comments]
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

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time
      include_examples 'not found'

      response '200', 'time tracker found' do
        schema '$ref': '#/definitions/time_tracker',
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

      include_examples 'access rights', :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time, success_code: '204'

      include_examples 'not found'

      response '204', 'time tracker found' do
        run_test!
      end
    end

    put 'Update an existing time tracker' do
      consumes 'application/json'
      tags 'Time trackers'
      parameter name: :id, in: :path, type: :string
      parameter name: :time_tracker, in: :body, schema: {
          '$ref': '#/definitions/time_tracker_update'
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
end
