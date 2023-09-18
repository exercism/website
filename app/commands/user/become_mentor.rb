class User::BecomeMentor
  include Mandate

  initialize_with :user, :track_slugs

  def call
    return if user.mentor? || user.reputation < User::MIN_REP_TO_MENTOR

    raise MissingTracksError if tracks.blank?

    ActiveRecord::Base.transaction do
      user.update!(
        became_mentor_at: Time.current,
        mentored_tracks: tracks
      )
    end
  end

  memoize
  def tracks
    Track.where(slug: track_slugs).tap do |tracks|
      raise InvalidTrackSlugsError, track_slugs.map(&:to_s) - tracks.map(&:slug) unless tracks.size == track_slugs.size
    end
  end
end
