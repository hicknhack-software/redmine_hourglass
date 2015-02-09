FactoryGirl.define do
  factory :user do |f|
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    login { Faker::Internet.user_name }
    mail { Faker::Internet.email }
    status 1
    language 'en'
  end
end