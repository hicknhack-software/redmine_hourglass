FactoryGirl.define do
  factory :project do
    name { Faker::App.name }
    description { Faker::Company.catch_phrase }
    homepage { Faker::Internet.domain_name }
    identifier { name.underscore }
    is_public true
    status 1
  end
end