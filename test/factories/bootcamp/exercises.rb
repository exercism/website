FactoryBot.define do
  factory :bootcamp_exercise, class: "Bootcamp::Exercise" do
    project { create(:bootcamp_project) }
    slug { SecureRandom.hex }
    idx { project.exercises.count + 1 }
    title { "Exercise Title" }
    description { "Exercise Description" }
    level_idx { (Bootcamp::Level.first || create(:bootcamp_level)).idx }
  end
end
