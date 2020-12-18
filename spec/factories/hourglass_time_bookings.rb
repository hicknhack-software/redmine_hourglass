FactoryBot.define do
  factory :time_booking, class: 'Hourglass::TimeBooking' do
    transient do
      user { create :user }
    end
    start { faker_between Date.today, Date.today, :morning }
    stop { faker_between Date.today, Date.today, :afternoon }
    time_log { create(:time_log, start: start, stop: stop, user: user) }
    time_entry { create(:time_entry, spent_on: start, hours: Hourglass::DateTimeCalculations.in_hours(stop - start), user: user) }
  end
end
