require 'swagger_helper'

describe 'Time trackers API', type: :request do
  let(:user) { create :admin }

  path '/time_trackers.json' do
    get 'Creates a blog' do
      produces 'application/json'
      
      response '200', 'index' do
        let(:key) { user.api_key }
        run_test!
      end

      response '401', 'unauthorized' do
        let(:key) { 'fake' }
        run_test!
      end

      # response '403', 'invalid request' do
      #   let(:key) { 'fake' }
      #   run_test!
      # end
    end
  end
end
