FactoryBot.define do
  factory :user_reputation_token, class: 'User::ReputationToken' do
    user
    category { :authoring }
    context_key { "authored_exercise/#{SecureRandom.hex(4)}" }
    reason { 'authored_exercise' }
  end
end
