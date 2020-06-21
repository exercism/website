FactoryBot.define do
  factory :badge, class: 'Badges::FirstSubmissionBadge' do
    user { create :user }
  end
end
