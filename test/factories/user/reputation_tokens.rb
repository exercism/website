FactoryBot.define do
  factory :user_reputation_token, class: 'User::ReputationToken' do
    user
    category { "exercise_authorship" }
    reason { "exercise_authorship" }
  end
end
