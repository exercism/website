class Bootcamp::Exercise < ApplicationRecord
  extend Mandate::Memoize

  self.table_name = "bootcamp_exercises"

  belongs_to :project, class_name: "Bootcamp::Project"
  belongs_to :level, foreign_key: :level_idx, primary_key: :idx, inverse_of: :exercises, class_name: "Bootcamp::Level"
  has_many :solutions, dependent: :destroy, class_name: "Bootcamp::Solution"
  has_many :submissions, through: :solutions
  has_many :exercise_concepts, dependent: :destroy, class_name: "Bootcamp::ExerciseConcept"
  has_many :concepts, through: :exercise_concepts

  default_scope -> { order(:level_idx, :idx) }
  scope :unlocked, -> { where('level_idx <= ?', Bootcamp::Settings.level_idx) }
  scope :part_1, -> { where(level_idx: 1..10) }
  scope :part_2, -> { where(level_idx: 11..200) }

  def to_param = slug
  def brain_buster? = !blocks_level_progression?
  def locked? = level_idx > Bootcamp::Settings.level_idx
  def unlocked? = !locked?
  def concepts = super.to_a.sort
  def language = config[:language] || "jikiscript"

  def major_project?
    return true if project.slug == 'games-and-apps'
    return true if %w[omniscience wordle-solver].include?(slug)

    false
  end

  def icon_url = "#{Exercism.config.website_icons_host}/bootcamp/exercises/#{project.slug}/#{slug}.svg"

  memoize
  def tasks
    config[:tasks].map.with_index do |task, idx|
      task[:instructions_html] = Markdown::Parse.(file_contents("task-#{idx + 1}.md"))
      task
    end
  end

  def num_tasks = tasks.size
  def editor_config = config[:editor_config] || {}

  memoize
  def config
    JSON.parse(file_contents('config.json'), symbolize_names: true)
  end

  memoize
  def introduction_html
    Markdown::Parse.(file_contents("introduction.md"))
  end

  def stub(type = "jiki")
    file_contents("stub.#{type}")
  end

  def default(type)
    file_contents("default.#{type}") || ""
  end

  def example(type = "jiki")
    file_contents("example.#{type}")
  end

  def readonly_ranges
    config[:readonly_ranges]
  end

  private
  def file_contents(filename)
    File.read(root_dir / "projects/#{project.slug}/exercises/#{slug}/#{filename}")
  end

  def root_dir
    return Rails.root / "test/repos/bootcamp_content" if Rails.env.test?

    Rails.root / "bootcamp_content"
  end
end
