class Concept < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  # TODO: Remove at ETL
  self.table_name = "track_concepts"

  friendly_id :slug, use: [:history]

  belongs_to :track, touch: true

  has_many :exercise_prerequisites,
    class_name: "Exercise::Prerequisite",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy
  has_many :unlocked_exercises, through: :exercise_prerequisites, source: :exercise

  has_many :exercise_taught_concepts,
    class_name: "Exercise::TaughtConcept",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy
  has_many :concept_exercises, through: :exercise_taught_concepts, source: :exercise

  has_many :exercise_practiced_concepts,
    class_name: "Exercise::PracticedConcept",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy
  has_many :practice_exercises, through: :exercise_practiced_concepts, source: :exercise

  has_many :authorships,
    class_name: "Concept::Authorship",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy
  has_many :authors,
    through: :authorships,
    source: :author

  has_many :contributorships,
    class_name: "Concept::Contributorship",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy
  has_many :contributors,
    through: :contributorships,
    source: :contributor

  scope :not_taught, lambda {
    where.not(id: Exercise::TaughtConcept.select(:track_concept_id))
  }

  after_destroy do
    SiteUpdates::NewConceptUpdate.where(%(params LIKE "%gid://website/Concept/#{id}%")).destroy_all
  end

  delegate :about, :introduction, :links, to: :git
  memoize
  def git
    Git::Concept.new(slug, "HEAD", repo_url: track.repo_url)
  end
end
