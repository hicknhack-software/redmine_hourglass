FactoryGirl.define do
  factory :time_entry_activity do
    sequence(:name) { |n| "#{Faker::Commerce.department(2)}#{n}" }
  end
end