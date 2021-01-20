FactoryBot.define do
  factory :user_acquired_badge, class: 'User::AcquiredBadge' do
    badge { create :member_badge }
    user { create :user }
  end
end
