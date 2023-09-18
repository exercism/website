class SerializeTracks
  include Mandate

  initialize_with :tracks, :user do
    # Materialise this so we're not ending up with nested queries
    @tracks = tracks.to_a if tracks.is_a?(ActiveRecord::Relation)
  end

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

    query = UserTrack.
      where(user:).
      includes(:user, track: [:concepts])

    # Once we hit ~20 tracks, it's quicker just to get them all.
    query = query.where(track: tracks) if tracks.size < 20
    query.index_by(&:track_id)
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
