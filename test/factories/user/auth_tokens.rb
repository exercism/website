FactoryBot.define do
  factory :user_auth_token, class: 'User::AuthToken' do
    user
  end
end
