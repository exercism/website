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

  trait :even_or_odd do
    slug { "even-or-odd" }
    project { Bootcamp::Project.find_by(slug: "numbers") || create(:bootcamp_project, slug: "numbers") }
  end

  trait :manual_solve do
    slug { "manual-solve" }
    project { Bootcamp::Project.find_by(slug: "maze") || create(:bootcamp_project, slug: "maze") }
  end

  trait :manual_solve_with_bonus_task do
    slug { "manual-solve-with-bonus-task" }
    project { Bootcamp::Project.find_by(slug: "maze") || create(:bootcamp_project, slug: "maze") }
  end

  trait :automated_solve do
    slug { "automated-solve" }
    project { Bootcamp::Project.find_by(slug: "maze") || create(:bootcamp_project, slug: "maze") }
  end

  trait :automated_solve_mini do
    slug { "automated-solve-mini" }
    project { Bootcamp::Project.find_by(slug: "maze") || create(:bootcamp_project, slug: "maze") }
  end

  trait :acronym do
    slug { "acronym" }
    project { Bootcamp::Project.find_by(slug: "string-puzzles") || create(:bootcamp_project, slug: "string-puzzles") }
  end
end
