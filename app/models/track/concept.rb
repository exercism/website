class Track::Concept < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  belongs_to :track

  scope :not_taught, lambda {
    where.not(id: Exercise::TaughtConcept.select(:track_concept_id))
  }

  delegate :about, :links, to: :git

  # TODO: Read from git
  def blurb
    "C# structs are closely related to classes. They have state and behavior. They have constructors that take arguments, instances can be assigned, tested for equality and stored in collections." # rubocop:disable Layout/LineLength
  end

  # Cache this
  def num_exercises
    3
  end

  memoize
  def git
    Git::Concept.new(track.slug, slug, "HEAD")
  end
end
