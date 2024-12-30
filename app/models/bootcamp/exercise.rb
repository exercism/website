class Bootcamp::Exercise < ApplicationRecord
  extend Mandate::Memoize

  self.table_name = "bootcamp_exercises"

  belongs_to :project, class_name: "Bootcamp::Project"
  belongs_to :level, foreign_key: :level_idx, primary_key: :idx, inverse_of: :exercises, class_name: "Bootcamp::Level"
  has_many :solutions, dependent: :destroy, class_name: "Bootcamp::Solution"
  has_many :submissions, through: :solutions
  has_many :exercise_concepts, dependent: :destroy, class_name: "Bootcamp::ExerciseConcept"
  has_many :concepts, through: :exercise_concepts

  default_scope -> { order(:idx) }
  scope :unlocked, -> { where('level_idx < ?', Settings.level_idx) }

  def to_param = slug
  def locked? = level_idx > Settings.level_idx
  def unlocked? = !locked?
  def concepts = super.to_a.sort

  def icon_url = "/exercise-icons/#{project.slug}/#{slug}.svg"

  memoize
  def tasks
    config[:tasks].map.with_index do |task, idx|
      task[:instructions_html] = Markdown::Parse.(file_contents("task-#{idx + 1}.md"))
      task
    end
  end

  def num_tasks = tasks.size

  memoize
  def config
    JSON.parse(file_contents('config.json'), symbolize_names: true)
  end

  memoize
  def introduction_html
    Markdown::Parse.(file_contents("introduction.md"))
  end

  def stub
    file_contents("stub.jk")
  end

  def readonly_ranges
    config[:readonly_ranges]
  end

  private
  def file_contents(filename)
    File.read(Rails.root / "content/projects/#{project.slug}/exercises/#{slug}/#{filename}")
  end
end
