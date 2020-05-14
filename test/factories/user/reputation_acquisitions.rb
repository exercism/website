FactoryBot.define do
  factory :user_reputation_acquisition, class: 'User::ReputationAcquisition' do
    user
    amount { 1 }
    category { "misc" }
    reason { "misc" } 
  end
end
