FactoryGirl.define do
  factory :role do
    name { "#{[*1..1000].sample}. #{Faker::Base.fetch('name.title.job')}"  }
  end
end
