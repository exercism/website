FactoryBot.define do
  factory :first_submission_badge, class: 'Badges::FirstSubmissionBadge' do
    user { create :user }
  end
end
