FactoryBot.define do
  factory :bug_reports do
    user { create :user }
    content_markdown { "report" }
  end
end
