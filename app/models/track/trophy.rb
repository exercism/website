class Track::Trophy < ApplicationRecord
  has_many :acquired_trophies, class_name: "UserTrack::AcquiredTrophy", dependent: :destroy

  def self.valid_track_slugs = []

  def self.for_track(track)
    where(%{
      JSON_LENGTH(valid_track_slugs) = 0
      OR
      JSON_CONTAINS(valid_track_slugs, '"#{track.slug}"')
          }).sort_by(&:order)
  end

  def reseed!
    update!(valid_track_slugs: Array(self.class.valid_track_slugs))
  end

  def self.lookup!(slug)
    klass = "track/trophies/#{slug}_trophy".camelize.constantize

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

  def enabled_for_track?(track)
    return true if self.valid_track_slugs.empty?

    self.valid_track_slugs.include?(track.slug)
  end

  # Stub to allow trophies to short-circuit queueing
  def worth_queuing?(**_context) = true
  def award?(_user_track) = raise "Implement this method in the child class"
  def icon = super.to_sym

  def send_email_on_acquisition? = true

  # Stub that children can override to generate
  # notifications when they are created
  def notification_key = nil
  def order = 999
end
