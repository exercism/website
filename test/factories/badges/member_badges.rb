FactoryBot.define do
  factory :member_badge, class: 'Badges::MemberBadge' do
    user { create :user }
  end
end
