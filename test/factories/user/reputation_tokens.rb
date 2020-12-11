FactoryBot.define do
  factory :user_reputation_token, class: 'User::ReputationToken' do
    user
    category { :authoring }
    reason { 'authored_exercise' }
  end
end
