class Exercise < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  # TODO: Remove this once we use external icons
  include Webpacker::Helper
  include ActionView::Helpers::AssetUrlHelper

  friendly_id :slug, use: [:history]

  belongs_to :track

  # TODO: Remove this dependent: :destroy before launch - exercises should never be destroyed
  has_many :solutions, dependent: :destroy
  has_many :submissions, through: :solutions

  # TODO: Remove this dependent: :destroy before launch - exercises should never be destroyed
  has_many :exercise_prerequisites,
    class_name: "Exercise::Prerequisite",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :prerequisites,
    through: :exercise_prerequisites,
    source: :concept

  # TODO: Remove this dependent: :destroy before launch - exercises should never be destroyed
  has_many :authorships,
    class_name: "Exercise::Authorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :authors,
    through: :authorships,
    source: :author

  # TODO: Remove this dependent: :destroy before launch - exercises should never be destroyed
  has_many :contributorships,
    class_name: "Exercise::Contributorship",
    inverse_of: :exercise,
    dependent: :destroy
  has_many :contributors,
    through: :contributorships,
    source: :contributor

  scope :without_prerequisites, lambda {
    where.not(id: Exercise::Prerequisite.select(:exercise_id))
  }

  delegate :solution_files, :introduction, :instructions, :source, :source_url, to: :git

  before_create do
    self.synced_to_git_sha = git_sha unless self.synced_to_git_sha
  end

  def git_type
    self.class.name.sub("Exercise", "").downcase
  end

  def concept_exercise?
    is_a?(ConceptExercise)
  end

  def practice_exercise?
    is_a?(PracticeExercise)
  end

  def to_param
    slug
  end

  # TODO: Remove once in the db
  def blurb
    "Atoms are internally represented"
  end

  # TODO: Remove once in the db
  def icon_url
    asset_pack_url(
      "media/images/exercises/#{icon_name}.svg",
      host: Rails.application.config.action_controller.asset_host
    )
  end

  # TODO: Implement this properly
  def icon_name
    if title[0].ord < 70
      suffix = "queen-attack"
    elsif title[0].ord < 75
      suffix = "rocket"
    elsif title[0].ord < 80
      suffix = "minesweeper"
    elsif title[0].ord < 85
      suffix = "annalyn"
    else
      suffix = "butterflies"
    end

    "sample-#{suffix}"
  end

  def prerequisite_exercises
    ConceptExercise.that_teach(prerequisites).distinct
  end

  memoize
  def git
    Git::Exercise.new(slug, git_type, git_sha, repo_url: track.repo_url)
  end
end
