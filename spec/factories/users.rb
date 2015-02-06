FactoryGirl.define do
  factory :user do |f|
    f.firstname { Faker::Name.first_name }
    f.lastname { Faker::Name.last_name }
    f.login { Faker::Internet.user_name }
    f.mail { Faker::Internet.email }
    f.status 1
    f.language 'en'
  end
end