FactoryBot.define do
  factory :issue_priority do
    sequence(:name) { |n| "#{Faker::Color.color_name}-#{n}" }
  end

  factory :issue_status do
    name { Faker::Adjective.negative }
    # description { Faker::Lorem.words(number: 10) } # note: not in Redmine <5.x
  end

  factory :tracker do
    sequence(:name) { |n| "#{Faker::Ancient.name}-#{n}" }
    # description { Faker::Lorem.words(number: 10) } # note: not in Redmine <5.x
    default_status { create :issue_status }
  end

  factory :issue do
    project { create(:project, trackers: [(create :tracker)]) }
    author { create :user }
    sequence(:subject, 'abc') { |n| "Not working on #{Faker::Computer.os.gsub(/\d+/, '')}-#{n}" }
    description { Faker::Lorem.words(number: 10) }
    tracker { project.trackers.first }
    priority { create :issue_priority }
  rescue ActiveRecord::RecordInvalid => e
    p "#{e.record} - #{e.record&.errors&.full_messages&.join(', ')}"
    raise
  end
end
