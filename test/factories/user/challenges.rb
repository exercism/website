FactoryBot.define do
  factory :user_challenge, class: 'User::Challenge' do
    user { create :user }
    challenge_id { User::Challenge::CHALLENGES.first }
  end
end
