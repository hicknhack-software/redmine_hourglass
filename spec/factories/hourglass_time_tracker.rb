FactoryGirl.define do
  factory :time_tracker, class: 'Hourglass::TimeTracker' do
    factory :time_tracker_with_comments do
      comments { Faker::Hacker.say_something_smart }
    end
  end
end
