FactoryBot.define do
  factory :github_issue_label, class: 'Github::IssueLabel' do
    issue { create :github_issue }
    name { 'help-wanted' }

    trait :random do
      issue { create :github_issue, :random }
      name { "label-#{SecureRandom.hex(4)}" }
    end
  end
end
