FactoryBot.define do
  factory :problem_report do
    type { :bug }
    user { create :user }
    content_markdown { "report" }
  end
end
