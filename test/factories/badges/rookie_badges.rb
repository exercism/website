FactoryBot.define do
  factory :rookie_badge, class: 'Badges::RookieBadge' do
    user { create :user }
  end
end
