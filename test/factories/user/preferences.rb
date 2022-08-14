FactoryBot.define do
  factory :user_preferences, class: 'User::Preferences' do
    user { create :user }
  end
end
