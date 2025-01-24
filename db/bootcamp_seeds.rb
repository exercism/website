# rubocop:disable Layout/LineLength:
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
# rubocop:enable Layout/LineLength:

JSON.parse(File.read(Rails.root / "bootcamp_content/levels/config.json"), symbolize_names: true).each.with_index do |details, idx|
  idx += 1
  level = Bootcamp::Level.find_or_create_by!(idx:) do |l|
    l.title = ""
    l.description = ""
    l.content_markdown = ""
  end

  level.update!(
    title: details[:title],
    description: details[:description],
    content_markdown: File.read(Rails.root / "bootcamp_content/levels/#{idx}.md")
  )
end

JSON.parse(File.read(Rails.root / "bootcamp_content/concepts/config.json"), symbolize_names: true).each do |details|
  concept = Bootcamp::Concept.find_or_create_by!(slug: details[:slug]) do |c|
    c.title = ""
    c.description = ""
    c.content_markdown = ""
    c.level_idx = details[:level]
  end

  concept.update!(
    parent: details[:parent] ? Bootcamp::Concept.find_by!(slug: details[:parent]) : nil,
    title: details[:title],
    description: details[:description],
    content_markdown: concept_intro_for(details[:slug]),
    level_idx: details[:level],
    apex: details[:apex] || false
  )
end

projects = %w[
  drawing
  maze
  weather
  golf
  space-invaders
  time
  rock-paper-scissors
  number-puzzles
]

projects.each do |project_slug|
  project_config = project_config_for(project_slug)
  project = Bootcamp::Project.find_or_create_by!(slug: project_slug) do |p|
    p.title = project_config[:title]
    p.description = project_config[:description]
    p.introduction_markdown = project_intro_for(project_slug)
  end
  project.update!(
    title: project_config[:title],
    description: project_config[:description],
    introduction_markdown: project_intro_for(project_slug)
  )
  project_config[:exercises].each do |exercise_slug|
    exercise_config = exercise_config_for(project_slug, exercise_slug)
    exercise = project.exercises.find_or_create_by!(slug: exercise_slug) do |e|
      e.idx = exercise_config[:idx]
      e.title = ""
      e.description = ""
      e.level_idx = exercise_config[:level]
    end
    exercise.update!(
      idx: exercise_config[:idx],
      title: exercise_config[:title],
      description: exercise_config[:description],
      level_idx: exercise_config[:level],
      concepts: (exercise_config[:concepts] || []).map do |slug|
                  Bootcamp::Concept.find_by!(slug:)
                end
    )
  end
end

# Bootcamp::UserProject::CreateAll.(User.find_by!(handle: 'iHiD'))
