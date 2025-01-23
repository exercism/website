FactoryBot.define do
  factory :bootcamp_exercise, class: "Bootcamp::Exercise" do
    project { create(:bootcamp_project) }
    slug { SecureRandom.hex }
    idx { project.exercises.count + 1 }
    title { "Exercise Title" }
    description { "Exercise Description" }
    level_idx { (Bootcamp::Level.first || create(:bootcamp_level)).idx }
  end

  trait :penguin do
    slug { "penguin" }
    project { Bootcamp::Project.find_by(slug: "drawing") || create(:bootcamp_project, slug: "drawing") }
  end
end
