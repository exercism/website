FactoryBot.define do
  factory :bootcamp_level, class: "Bootcamp::Level" do
    idx { Bootcamp::Level.count + 1 }
    title { "Level Title" }
    description { "Level Description" }
    content_markdown { "Level Content Markdown" }
  end
end
