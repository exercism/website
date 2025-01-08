FactoryBot.define do
  factory :bootcamp_concept, class: "Bootcamp::Concept" do
    level { Bootcamp::Level.first || create(:bootcamp_level) }
    slug { "Some Concept" }
    title { "Some Concept" }
    description { "Some Concept" }
    content_markdown { "Some Concept" }
  end
end
