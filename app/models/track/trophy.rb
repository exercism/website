class Track::Trophy < ApplicationRecord
  has_many :acquired_trophies, class_name: "UserTrack::AcquiredTrophy", dependent: :destroy

  def self.valid_track_slugs = []

  def self.for_track(track)
    where(%{
      JSON_LENGTH(valid_track_slugs) = 0
      OR
      JSON_CONTAINS(valid_track_slugs, '"#{track.slug}"')
    })
  end

  def reseed!
    update!(valid_track_slugs: Array(self.class.valid_track_slugs))
  end

  def self.lookup!(category, slug)
    klass = "track/trophies/#{category}/#{slug}_trophy".camelize.constantize

    # This avoids race conditions
    begin
      klass.first || klass.create!
    rescue ActiveRecord::RecordNotUnique
      klass.first
    end
  end

  before_create do
    self.valid_track_slugs = Array(self.class.valid_track_slugs)
  end

  # Stub to allow trophies to short-circuit queueing
  def self.worth_queuing?(track:, **_context)
    return true if self.valid_track_slugs.empty?

    self.valid_track_slugs.include?(track.slug)
  end

  def award?(_user_track) = raise "Implement this method in the child class"
  def icon = super.to_sym
end
