FactoryBot.define do
  factory :user_reputation_period, class: 'User::ReputationPeriod' do
    user { create :user }
    period { :forever }
    about { :everything }
    category { :any }
    reputation { 0 }
    dirty { false }

    trait :dirty do
      dirty { true }
    end
  end
end
