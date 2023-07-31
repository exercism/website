FactoryBot.define do
  factory :user_data, class: 'User::Data' do
    # Creating a user makes its data, so this dance
    # deletes the one that gets created by default and
    # attaches this factory instead.
    user { create(:user).tap { |u| u.data.destroy } }
  end
end
