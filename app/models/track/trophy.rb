class Track::Trophy < ApplicationRecord
  class << self
    attr_accessor :valid_track_slugs
  end

  has_many :acquired_trophies, class_name: "UserTrack::AcquiredTrophy", dependent: :destroy

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

  def self.lookup!(language, slug)
    klass = "track/trophies/#{language}/#{slug}_trophy".camelize.constantize

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

  # Stub to allow badges to short-circuit queueing
  def award?(_user, _track) = raise "Implement this method in the child class"
  def icon = super.to_sym
end
