FactoryGirl.define do
  factory :time_booking, class: 'Chronos::TimeBooking' do
    transient do
      user nil
    end
    start { Faker::Time.between Time.now, Time.now, :morning }
    stop { Faker::Time.between Time.now, Time.now, :afternoon }
    time_log { create(:time_log, start: start, stop: stop, user: user) }
    time_entry { create(:time_entry, spent_on: start, hours: (stop - start)/ 1.hour.to_f, user: user) }
  end
end