return unless Rails.env.development?

# rubocop:disable Layout/LineLength
Bootcamp::UserProject.destroy_all
Bootcamp::Submission.destroy_all
Bootcamp::Solution.destroy_all
Bootcamp::Exercise.destroy_all
Bootcamp::Project.destroy_all
Bootcamp::Concept.destroy_all
Bootcamp::Level.destroy_all

def concept_intro_for(slug) = File.read(Rails.root / "bootcamp_content/concepts/#{slug}.md")

def project_config_for(slug) = JSON.parse(File.read(Rails.root / "bootcamp_content/projects/#{slug}/config.json"),
  symbolize_names: true)

def project_intro_for(slug) = File.read(Rails.root / "bootcamp_content/projects/#{slug}/introduction.md")

def exercise_code_for(project_slug,
                      exercise_slug) = File.read(Rails.root / "bootcamp_content/projects/#{project_slug}/exercises/#{exercise_slug}/code")

def exercise_config_for(project_slug,
                        exercise_slug) = JSON.parse(
                          File.read(Rails.root / "bootcamp_content/projects/#{project_slug}/exercises/#{exercise_slug}/config.json"), symbolize_names: true
                        )

JSON.parse(File.read(Rails.root / "bootcamp_content/levels/config.json"), symbolize_names: true).each.with_index do |details, idx|
  idx += 1
  Bootcamp::Level.create!(
    idx:,
    title: details[:title],
    description: details[:description],
    content_markdown: File.read(Rails.root / "bootcamp_content/levels/#{idx}.md")
  )
end

JSON.parse(File.read(Rails.root / "bootcamp_content/concepts/config.json"), symbolize_names: true).each do |details|
  Bootcamp::Concept.create!(
    slug: details[:slug],
    parent: details[:parent] ? Bootcamp::Concept.find_by!(slug: details[:parent]) : nil,
    title: details[:title],
    description: details[:description],
    content_markdown: concept_intro_for(details[:slug]),
    level_idx: details[:level],
    apex: details[:apex] || false
  )
end

projects = %w[
  two-fer
  rock-paper-scissors
  number-puzzles
  drawing
  maze
  wordle
  weather
]

projects.each do |project_slug|
  project_config = project_config_for(project_slug)
  project = Bootcamp::Project.create!(
    slug: project_slug,
    title: project_config[:title],
    description: project_config[:description],
    introduction_markdown: project_intro_for(project_slug)
  )
  project_config[:exercises].each.with_index do |exercise_slug, idx|
    exercise_config = exercise_config_for(project_slug, exercise_slug)
    project.exercises.create!(
      slug: exercise_slug,
      idx: idx + 1,
      title: exercise_config[:title],
      description: exercise_config[:description],
      level_idx: exercise_config[:level],
      concepts: exercise_config[:concepts].map do |slug|
                  Bootcamp::Concept.find_by!(slug:)
                end
    )
  end
end

Bootcamp::UserProject::CreateAll.(User.find_by!(handle: 'iHiD'))

# rubocop:enable Layout/LineLength
