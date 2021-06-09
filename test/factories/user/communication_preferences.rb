FactoryBot.define do
  factory :user_communication_preferences, class: 'User::CommunicationPreferences' do
    user { create :user }
  end
end
