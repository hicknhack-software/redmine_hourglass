FactoryBot.define do
  factory :project do
    name { Faker::App.name }
    description { Faker::Company.catch_phrase }
    homepage { Faker::Internet.domain_name }
    sequence(:identifier) { |n| "#{name.underscore.gsub(' ', '_')}_#{n}" }
    is_public { true }
    status { 1 }
    after(:create) do |project|
      project.enabled_modules.create name: :redmine_hourglass
    end
  end
end
