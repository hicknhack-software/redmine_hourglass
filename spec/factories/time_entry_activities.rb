FactoryBot.define do
  factory :time_entry_activity do
    sequence(:name) { |n| "#{Faker::Commerce.department(max: 2)}#{n}" }
  end
end