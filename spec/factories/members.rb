FactoryBot.define do
  factory :member do
    user
    project
    
    transient do
      permissions { [] }
    end
    
    before(:create) do |member, evaluator|
      member.roles << FactoryBot.create(:role, permissions: evaluator.permissions)
    end
  end
end
