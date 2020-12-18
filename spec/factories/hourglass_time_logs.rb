FactoryBot.define do
  factory :time_log, class: 'Hourglass::TimeLog' do
    user
    start { faker_between Date.today, Date.today, :morning }
    stop { faker_between Date.today, Date.today, :afternoon }
    factory :time_log_with_comments do
      comments { Faker::Hacker.say_something_smart }
    end
  end
end
