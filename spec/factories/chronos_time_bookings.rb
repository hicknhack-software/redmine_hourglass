FactoryGirl.define do
  factory :time_booking, class: 'Chronos::TimeBooking' do
    transient do
      user { create :user }
    end
    start { Faker::Time.between Time.now, Time.now, :morning }
    stop { Faker::Time.between Time.now, Time.now, :afternoon }
    time_log { create(:time_log, start: start, stop: stop, user: user) }
    time_entry { create(:time_entry, spent_on: start, hours: Chronos::DateTimeCalculations.in_hours(stop - start), user: user) }
  end
end