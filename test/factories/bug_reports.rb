FactoryBot.define do
  factory :bug_report do
    user { create :user }
    content_markdown { "report" }
  end
end
