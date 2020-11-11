class Track::Concept < ApplicationRecord
  extend FriendlyId
  extend Mandate::Memoize

  friendly_id :slug, use: [:history]

  belongs_to :track

  scope :not_taught, lambda {
    where.not(id: Exercise::TaughtConcept.select(:track_concept_id))
  }

  delegate :about, :links, to: :git

  memoize
  def git
    Git::Concept.new(track.slug, slug, "HEAD")
  end
end
