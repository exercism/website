class UserTrack::Create
  include Mandate

  initialize_with :user, :track

  def call
    ::UserTrack.create_or_find_by!(user:, track:).tap do |user_track|
      log_metric!(user_track)
    end
  end

  def log_metric!(user_track)
    Metric::Queue.(:join_track, user_track.created_at, user_track:, track:, user:)
  end
end
