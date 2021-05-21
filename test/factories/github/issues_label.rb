FactoryBot.define do
  factory :github_issue_label, class: 'Github::IssueLabel' do
    issue { create :github_issue }
    label { 'help-wanted' }

    trait :random do
      issue { create :github_issue, :random }
      label { "label-#{SecureRandom.hex(4)}" }
    end
  end
end
