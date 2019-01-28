FactoryBot.define do
  factory :user do
    firstname { Faker::Name.first_name }
    lastname { Faker::Name.last_name }
    login { Faker::Internet.unique.user_name }
    mail { Faker::Internet.email }
    status 1
    language 'en'

    trait :admin do
      admin 1
    end

    trait :as_member do
      transient do
        permissions []
      end
      after(:create) do |user, evaluator|
        user.memberships << FactoryBot.create(:member, user: user, permissions: evaluator.permissions)
      end
    end
  end
end
