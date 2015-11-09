FactoryGirl.define do
  factory :time_entry do
    project
    user
    activity { create :time_entry_activity }
    hours 1
    spent_on Date.yesterday
  end
end