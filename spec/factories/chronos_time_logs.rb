FactoryGirl.define do
  factory :time_log, class: 'Chronos::TimeLog' do
    user
    start { Faker::Time.between Time.now, Time.now, :morning }
    stop { Faker::Time.between Time.now, Time.now, :afternoon }
    factory :timelog_with_comments do
      comments { Faker::Hacker.say_something_smart }
    end
  end
end