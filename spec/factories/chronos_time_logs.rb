FactoryGirl.define do
  factory :time_log, class: 'Chronos::TimeLog' do
    user
    start { Faker::Time.between Date.today, Date.today, :morning }
    stop { Faker::Time.between Date.today, Date.today, :afternoon }
    factory :time_log_with_comments do
      comments { Faker::Hacker.say_something_smart }
    end
  end
end
