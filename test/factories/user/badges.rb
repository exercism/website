FactoryBot.define do
  factory :user_badge, class: 'User::Badge' do
    user
    badge
  end
end
