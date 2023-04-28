class SerializeTracks
  include Mandate

  initialize_with :tracks, :user

  def call
    sorted_tracks.map do |track|
      SerializeTrack.(
        track,
        user_tracks[track.id],
        has_notifications: !!notification_counts_by_track_id[track.id]&.positive?
      )
    end
  end

  private
  def sorted_tracks
    tracks.sort_by do |track|
      "#{joined?(track) ? 0 : 1} | #{track.title.downcase}"
    end
  end

  memoize
  def user_tracks
    return {} unless user

    UserTrack.
      where(user:).
      where(track: tracks).
      includes(:user, track: [:concepts]).
      index_by(&:track_id)
  end

  memoize
  def notification_counts_by_track_id
    return {} unless user

    user.notifications.unread.
      where(track_id: tracks.map(&:id)).
      group(:track_id).count
  end

  def joined?(track)
    user_tracks.key?(track.id)
  end
end
