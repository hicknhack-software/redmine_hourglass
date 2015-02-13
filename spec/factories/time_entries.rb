FactoryGirl.define do
  factory :time_entry do
    project
    user
    activity_id 9
    hours 1
    spent_on Date.yesterday
  end
end