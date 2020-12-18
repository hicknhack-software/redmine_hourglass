FactoryBot.define do
  date = Date.yesterday
  factory :time_entry do
    project
    user
    author { user }
    activity { create :time_entry_activity }
    hours { 1 }
    spent_on { date }
  end
end