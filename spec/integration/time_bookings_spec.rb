require_relative '../swagger_helper'

describe 'Time bookings API', type: :request do
  let(:key) { user.api_key }

  path '/time_bookings.json' do
    get 'Lists all visible time bookings' do
      produces 'application/json'
      tags 'Time bookings'

      include_examples 'access rights', :hourglass_view_booked_time, :hourglass_view_own_booked_time

      response '200', 'time bookings found' do
        schema type: 'array',
               items: {
                   '$ref' => '#/definitions/time_booking',
                   required: %w(id start stop created_at updated_at)
               },
               title: 'Array'
        let(:user) { create :user, :as_member, permissions: [:hourglass_view_booked_time] }

        before do
          @time_booking = create :time_booking, project: user.projects.first, user: user
          @time_booking2 = create :time_booking
          create :member, project: @time_booking2.project, user: user, permissions: [:hourglass_view_booked_time]
        end

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data.length).to eq 2
          expect(data.first[:id]).to eq @time_booking.id
          expect(Time.parse(data.first[:start])).to eq @time_booking.start
          expect(data.first[:time_entry][:user_id]).to eq @time_booking.time_entry.user_id
          expect(data.second[:time_entry][:comments]).to eq @time_booking2.time_entry.comments
        end
      end
    end
  end

  path '/time_bookings/{id}.json' do
    get 'Find time booking by ID' do
      produces 'application/json'
      tags 'Time bookings'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, :as_member, permissions: [:hourglass_view_booked_time, :hourglass_view_booked_time] }
      let(:time_booking) { create :time_booking, project: user.projects.first, user: user }
      let(:id) { time_booking.id }

      include_examples 'access rights', :hourglass_view_booked_time, :hourglass_view_own_booked_time, error_code: '404'
      include_examples 'not found'

      response '200', 'time booking found' do
        schema '$ref' => '#/definitions/time_booking',
               required: %w(id start stop created_at updated_at)

        include_examples 'has a valid response'

        it 'returns correct data' do
          data = JSON.parse(response.body, symbolize_names: true)
          expect(data[:id]).to eq time_booking.id
          expect(Time.parse(data[:start])).to eq time_booking.start
          expect(Time.parse(data[:stop])).to eq time_booking.stop
          expect(data[:time_entry][:user_id]).to eq time_booking.time_entry.user_id
          expect(data[:comments]).to eq time_booking.comments
        end
      end
    end

    delete 'Deletes a time booking' do
      tags 'Time bookings'
      parameter name: :id, in: :path, type: :string

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_booked_time, :hourglass_view_booked_time] }
      let(:time_booking) { create :time_booking, project: user.projects.first, user: user }
      let(:id) { time_booking.id }

      include_examples 'access rights', :hourglass_edit_booked_time, :hourglass_edit_own_booked_time, success_code: '204', error_code: '404', extra_permission: [:hourglass_view_booked_time, :hourglass_view_own_booked_time]

      include_examples 'not found'

      response '204', 'time booking deleted' do
        run_test!
      end
    end

    put 'Update an existing time booking' do
      consumes 'application/json'
      tags 'Time bookings'
      parameter name: :id, in: :path, type: :string
      parameter name: :time_booking, in: :body, schema: {
          '$ref' => '#/definitions/time_booking_update'
      }

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_booked_time, :hourglass_view_booked_time] }
      let(:id) do
        time_booking = create :time_booking, project: user.projects.first, user: user
        time_booking.id
      end
      let(:time_booking) { {time_booking: {comments: 'test2'}} }

      include_examples 'access rights', :hourglass_book_time, :hourglass_book_own_time, :hourglass_edit_booked_time, :hourglass_edit_own_booked_time, success_code: '204', error_code: '404', extra_permission: [:hourglass_view_booked_time, :hourglass_view_own_booked_time]

      include_examples 'not found'
      context do
        let(:time_booking) do
          project = create :project
          create :member, project: project, user: user, permissions: [:hourglass_edit_booked_time, :hourglass_view_booked_time]
          {time_booking: {project_id: project.id}}
        end
        response '204', 'time booking found' do
          run_test!

          it 'changes the time booking' do
            expect(Hourglass::TimeBooking.find(id).comments).to eq time_booking[:time_booking][:comments]
          end
        end

        include_examples 'error message', 'time booking not updated', proc { |example|
          tt = Hourglass::TimeBooking.find id
          tt.comments = (0..500).map(&:to_s).join('')
          tt.save validate: false
        }
      end
    end
  end

  path '/time_bookings/bulk_destroy.json' do
    delete 'Deletes multiple time bookings at once' do
      tags 'Time bookings'
      parameter name: :'time_bookings[]', in: :query, type: :array, items: {type: :string}, collectionFormat: :multi

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_booked_time, :hourglass_view_booked_time] }
      let(:time_booking_ids) do
        tt1 = create :time_booking, project: user.projects.first, user: user
        tt2 = create :time_booking, project: user.projects.first
        [tt1.id, tt2.id]
      end

      let(:'time_bookings[]') { time_booking_ids }

      include_examples 'access rights', :hourglass_edit_booked_time, :hourglass_edit_own_booked_time, extra_permission: :hourglass_view_booked_time

      response '200', 'time bookings found' do
        run_test!
      end
    end
  end

  path '/time_bookings/bulk_update.json' do
    post 'Updates multiple time bookings at once' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time bookings'
      parameter name: :time_bookings, in: :body, type: :object, additionalProperties: {'$ref' => '#/definitions/time_booking'}, description: 'takes an object of time bookings'

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_booked_time, :hourglass_view_booked_time] }
      let(:time_booking_ids) do
        tt1 = create :time_booking, project: user.projects.first, user: user
        tt2 = create :time_booking
        [tt1.id, tt2.id]
      end

      let(:time_bookings) { {time_bookings: {time_booking_ids[0] => {comments: 'test3'}, time_booking_ids[1] => {comments: 'test4'}}} }

      include_examples 'access rights', :hourglass_book_time, :hourglass_book_own_time, :hourglass_edit_booked_time, :hourglass_edit_own_booked_time, error_code: '403', extra_permission: :hourglass_view_booked_time

      response '200', 'time bookings found' do
        run_test!

        it 'changes the time bookings allowed for' do
          expect(Hourglass::TimeBooking.find(time_booking_ids.first).comments).to eq 'test3'
          expect(Hourglass::TimeBooking.find(time_booking_ids.last).comments).to be_nil
        end
      end
    end
  end

  path '/time_bookings/bulk_create.json' do
    post 'Create multiple time bookings at once' do
      consumes 'application/json'
      produces 'application/json'
      tags 'Time bookings'
      parameter name: :time_bookings, in: :body, type: :array, items: {'$ref' => '#/definitions/time_booking'}, description: 'takes an array of time bookings'

      let(:user) { create :user, :as_member, permissions: [:hourglass_edit_booked_time] }

      let(:time_bookings) do
        {
            time_bookings: [
                {user_id: user.id, project_id: user.projects.first.id, activity_id: create(:time_entry_activity).id,
                 start: Faker::Time.between(Date.today, Date.today, :morning),
                 stop: Faker::Time.between(Date.today, Date.today, :afternoon)}
            ]
        }
      end

      include_examples 'access rights', :hourglass_edit_booked_time, :hourglass_edit_own_booked_time, error_code: '400'

      response '200', 'time bookings found' do
        let(:time_bookings) do
          activity = create :time_entry_activity
          project = user.projects.first
          {
              time_bookings: [
                  {user_id: user.id, project_id: project.id, activity_id: activity.id,
                   start: Faker::Time.between(Date.today, Date.today, :morning),
                   stop: Faker::Time.between(Date.today, Date.today, :afternoon)},
                  {user_id: create(:user).id, project_id: project.id, activity_id: activity.id,
                   start: Faker::Time.between(Date.today, Date.today, :morning),
                   stop: Faker::Time.between(Date.today, Date.today, :afternoon)},
                  {user_id: create(:user).id, project_id: project.id, activity_id: activity.id,
                   start: Faker::Time.between(Date.today, Date.today, :morning),
                   stop: Faker::Time.between(Date.today, Date.today, :afternoon)}
              ]
          }
        end
        run_test!

        it 'creates the time bookings' do
          expect(Hourglass::TimeBooking.count).to eq 3
        end
      end
    end
  end
end
