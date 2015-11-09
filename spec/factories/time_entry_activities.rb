FactoryGirl.define do
  factory :time_entry_activity do
    name { Faker::Commerce.department }
  end
end