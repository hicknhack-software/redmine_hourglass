require 'swagger_helper'

describe 'Time trackers API', type: :request do
  let(:key) { user.api_key }

  path '/time_trackers.json' do
    get 'Returns a list of currently running time trackers the user is allowed to see' do
      produces 'application/json'
      tags 'Time trackers'

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time

      response '200', 'returns currently active time trackers visible to the user' do
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
end
