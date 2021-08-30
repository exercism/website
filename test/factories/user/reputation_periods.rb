FactoryBot.define do
  factory :user_reputation_period, class: 'User::ReputationPeriod' do
    user { create :user }
    period { :forever }
    about { :everything }
    category { :any }
    track_id { 0 }
    reputation { 5 }
    dirty { false }

    trait :dirty do
      dirty { true }
    end
  end
end
