FactoryBot.define do
  factory :user_preferences, class: 'User::Preferences' do
    # Creating a user makes preferences, so this dance
    # deletes the one that gets created by default and
    # attaches this factory instead.
    user { create(:user).tap { |u| u.preferences.destroy } }
  end
end
