FactoryGirl.define do
  factory :user do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    login { Faker::Internet.user_name }
    mail { Faker::Internet.email }
    status 1
    language 'en'

    factory :admin do
      admin 1
    end
  end
end
