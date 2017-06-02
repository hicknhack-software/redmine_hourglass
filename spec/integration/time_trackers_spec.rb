require 'swagger_helper'

describe 'Time trackers API', type: :request do
  let(:key) { user.api_key }

  path '/time_trackers.json' do
    get 'Returns a list of currently running time trackers' do
      produces 'application/json'
      tags 'Time Trackers'

      test_permissions :hourglass_view_tracked_time, :hourglass_view_own_tracked_time

      test_forbidden
      test_unauthorized
    end
  end
end
