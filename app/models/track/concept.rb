class Track::Concept < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  belongs_to :track

  has_many :exercise_prerequisites,
    class_name: "Exercise::Prerequisite",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy

  has_many :exercise_taught_concepts,
    class_name: "Exercise::TaughtConcept",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy

  has_many :user_track_learnt_concepts,
    class_name: "UserTrack::LearntConcept",
    foreign_key: :track_concept_id,
    inverse_of: :concept,
    dependent: :destroy

  scope :not_taught, lambda {
    where.not(id: Exercise::TaughtConcept.select(:track_concept_id))
  }

  delegate :about, :links, to: :git

  memoize
  def concept_exercises
    ConceptExercise.that_teach(self)
  end

  memoize
  def practice_exercises
    # TODO: consider if we want to return the practice exercises
    # with the concept as the prerequisite or as a practiced concept
    PracticeExercise.with_prerequisite(self)
  end

  memoize
  def git
    Git::Concept.new(slug, "HEAD", repo_url: track.repo_url)
  end
end
