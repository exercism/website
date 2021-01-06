FactoryBot.define do
  factory :scratchpad_page do
    author { create :user }
    about { create :concept_exercise }
    content_markdown { "Hello, world" }
    content_html { "<p>Hello, world</p>" }
  end
end
