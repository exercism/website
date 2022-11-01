class Track::UpdateBuildStatus
  include Mandate

  initialize_with :track

  def call
    Exercism.redis_tooling_client.set(track.build_status_key, build_status.to_json)
  end

  private
  def build_status
    {
      students:,
      submissions:
    }
  end

  def students
    {
      count: track.num_students,
      num_joined_per_day: (track.user_tracks.where('created_at >= ?', Time.current - 30.days).count / 30.0).ceil
    }
  end

  def submissions
    {
      count: track.submissions.count,
      num_submitted_per_day: (track.submissions.where('submissions.created_at >= ?', Time.current - 30.days).count / 30.0).ceil
    }
  end
end
