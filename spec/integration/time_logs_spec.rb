require_relative '../swagger_helper'

describe 'Time logs API', type: :request do
  let(:key) { user.api_key }

  path '/time_logs.json' do
    get 'Lists all visible time logs' do
      produces 'application/json'
      tags 'Time logs'

      include_examples 'access rights', :hourglass_view_tracked_time, :hourglass_view_own_tracked_time

      response '200', 'time logs found' do
        schema '$ref' => '#/definitions/index_response'

        let(:user) { create :user, :as_member, permissions: [:hourglass_view_tracked_time] }

        before do
          @time_log = create :time_log, user: user
          @time_log2 = create :time_log_with_comments
        end

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:count]).to eq 2
          first, second = data[:records]
          if first[:id] != @time_log.id
            second, first = [first, second]
          end
          expect(Time.parse(first[:start])).to eq @time_log.start.change(sec: 0)
          expect(first[:user_id]).to eq @time_log.user_id
          expect(second[:comments]).to eq @time_log2.comments
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
        schema '$ref' => '#/definitions/time_log',
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
          '$ref' => '#/definitions/time_log_update'
      }

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }
      let(:existing_time_log) { create :time_log, user: user }
      let(:id) { existing_time_log.id }
      let(:time_log) { {time_log: {comments: 'test2'}} }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time, success_code: '204'

      include_examples 'not found'
      context do
        let(:time_log) { {time_log: {stop: existing_time_log.stop + 1.hour}} }
        response '204', 'time log found' do
          run_test!

          it 'changes the time log' do
            expect(Hourglass::TimeLog.find(id).stop).to eq time_log[:time_log][:stop].change(sec: 0)
          end
        end

        include_examples 'error message', 'time log not updated', proc { |example|
          tt = Hourglass::TimeLog.find id
          tt.comments = (0..500).map(&:to_s).join('')
          tt.save validate: false
        }
      end
    end
  end

  path '/time_logs/{id}/book.json' do
    post 'Book a time log' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time logs'
      parameter name: :id, in: :path, type: :string
      parameter name: :time_booking, in: :body, schema: {
          '$ref' => '#/definitions/time_booking_create'
      }

      let(:user) { create :user, :as_member, permissions: [:hourglass_book_time] }
      let(:time_log) { create :time_log, user: user }
      let(:id) { time_log.id }
      let(:time_booking) { {time_booking: {
          project_id: user.projects.first.id, activity_id: create(:time_entry_activity).id
      }} }

      include_examples 'access rights', :hourglass_book_time, :hourglass_book_own_time
      include_examples 'not found'

      response '200', 'time log found' do
        schema '$ref' => '#/definitions/time_booking',
               required: %w(id start stop created_at updated_at)

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:time_log_id]).to eq time_log.id
          expect(data[:time_entry][:project_id]).to eq time_booking[:time_booking][:project_id]
          expect(data[:time_entry][:activity_id]).to eq time_booking[:time_booking][:activity_id]
          expect(Time.parse(data[:start])).to eq time_log.start.change(sec: 0)
          expect(Time.parse(data[:stop])).to eq time_log.stop.change(sec: 0)
        end
      end
    end
  end

  path '/time_logs/{id}/split.json' do
    post 'Split a time log' do
      produces 'application/json'
      tags 'Time logs'
      parameter name: :id, in: :path, type: :string
      parameter name: :split_at, in: :query, type: :dateTime, required: true

      let(:user) { create :user, :as_member, permissions: [:hourglass_track_time] }
      let(:time_log) { create :time_log, user: user }
      let(:split_at) { URI.encode (time_log.start + 10.minutes).utc.to_s }
      let(:id) { time_log.id }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time
      include_examples 'not found'

      response '200', 'time log found' do
        schema type: 'object',
               properties: {
                   time_log: {
                       '$ref' => '#/definitions/time_log',
                       required: %w(id start stop user_id created_at updated_at)
                   },
                   new_time_log: {
                       '$ref' => '#/definitions/time_log',
                       required: %w(id start stop user_id created_at updated_at)
                   }
               }

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:time_log][:id]).to eq time_log.id
          expect(Time.parse(data[:time_log][:start])).to eq time_log.start.change(sec: 0)
          expect(Time.parse(data[:new_time_log][:stop])).to eq time_log.stop.change(sec: 0)
        end
      end
    end
  end

  path '/time_logs/join.json' do
    post 'Joins multiple time logs' do
      produces 'application/json'
      tags 'Time logs'
      parameter name: :'ids[]', in: :query, type: :array, items: {type: :integer}, collectionFormat: :multi

      let(:user) { create :user, :as_member, permissions: [:hourglass_track_time] }
      let(:time_log) { create :time_log, user: user }
      let(:time_log2) { create :time_log, user: user, start: time_log.stop, stop: time_log.stop + 10.minutes }
      let(:'ids[]') { [time_log.id, time_log2.id] }

      include_examples 'access rights', :hourglass_track_time, :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time
      response '404', 'nothing found' do
        let(:'ids[]') { ['invalid'] }
        run_test!
      end

      response '200', 'time logs found' do
        schema type: 'object',
               properties: {
                   time_log: {
                       '$ref' => '#/definitions/time_log',
                       required: %w(id start stop user_id created_at updated_at)
                   }
               }                 

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(Time.parse(data[:start])).to eq time_log.start.change(sec: 0)
          expect(Time.parse(data[:stop])).to eq time_log2.stop.change(sec: 0)
        end
        
        context do
          let(:time_log2) { create :time_log, user: user, start: time_log.stop + 10.minutes, stop: time_log.stop + 20.minutes }
          include_examples 'error message', 'time logs not joined'
        end
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
        tt2 = create :time_log
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
      parameter name: :time_logs, in: :body, type: :object, additionalProperties: {'$ref' => '#/definitions/time_log'}, description: 'takes an object of time logs'

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time, :hourglass_view_tracked_time] }
      let(:time_log_ids) do
        tt1 = create :time_log_with_comments, user: user
        tt2 = create :time_log_with_comments
        [tt1.id, tt2.id]
      end

      let(:time_logs) { {time_logs: {time_log_ids[0] => {comments: 'test3'}, time_log_ids[1] => {comments: 'test4'}}} }

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

  path '/time_logs/bulk_book.json' do
    post 'Books multiple time logs at once' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time logs'
      parameter name: :time_bookings, in: :body, type: :object, additionalProperties: {'$ref' => '#/definitions/time_booking'}, description: 'takes an object of time bookings'

      let(:user) { create :user, :as_member, permissions: [:hourglass_book_time, :hourglass_view_tracked_time] }
      let(:time_logs) do
        tl1 = create :time_log_with_comments, user: user
        tl2 = create :time_log_with_comments
        [tl1, tl2]
      end

      let(:time_bookings) do
        tl1, tl2 = time_logs
        {time_bookings: {
            tl1.id => {project_id: tl1.user.projects.first.id, activity_id: create(:time_entry_activity).id},
            tl2.id => {}
        }
        }
      end

      include_examples 'access rights', :hourglass_book_time, :hourglass_book_own_time

      response '200', 'time logs found' do
        run_test!

        it 'books the time logs' do
          expect(time_logs.first.time_booking).to be
        end
      end
    end
  end

  path '/time_logs/bulk_create.json' do
    post 'Create multiple time logs at once' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time logs'
      parameter name: :time_logs, in: :body, type: :array, items: {'$ref' => '#/definitions/time_log'}, description: 'takes an array of time logs'

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_tracked_time] }

      let(:time_logs) do
        {time_logs: [
            build(:time_log, user: user),
            build(:time_log),
            build(:time_log)
        ]
        }
      end

      include_examples 'access rights', :hourglass_edit_tracked_time, :hourglass_edit_own_tracked_time

      response '200', 'time logs found' do
        run_test!

        it 'creates the time logs' do
          expect(Hourglass::TimeLog.count).to eq 3
        end
      end
    end
  end
end
