FactoryBot.define do
  factory :bootcamp_project, class: "Bootcamp::Project" do
    slug { "slug-#{SecureRandom.hex}" }
    title { "Project Title" }
    description { "Project Description" }
    introduction_markdown { "Project Introduction" }
  end
end
