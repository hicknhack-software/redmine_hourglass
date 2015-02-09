FactoryGirl.define do
  factory :time_log, class: 'Chronos::TimeLog' do
    user
    start { Faker::Time.backward 0, :morning }
    stop { Faker::Time.forward 0, :afternoon }
    factory :timelog_with_comments do
      comments { Faker::Hacker.say_something_smart }
    end
  end
end