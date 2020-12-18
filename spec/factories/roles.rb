FactoryBot.define do
  factory :role do
    name { "#{[*1..1000].sample}. #{Faker::Job.title[0..10]}"  }
  end
end
