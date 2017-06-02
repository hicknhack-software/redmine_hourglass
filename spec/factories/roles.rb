FactoryGirl.define do
  factory :role do
    name { Faker::Base.fetch('name.title.job') }
  end
end
