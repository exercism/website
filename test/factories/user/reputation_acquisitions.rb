FactoryBot.define do
  factory :user_reputation_acquisition, class: 'User::ReputationAcquisition' do
    user
    category { :exercise_authorship }
    reason { "exercise_authorship" }
  end
end
