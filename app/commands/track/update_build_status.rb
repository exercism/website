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
      num_joined_per_day: average_number_per_day(track.user_tracks, UserTrack)
    }
  end

  def submissions
    {
      count: track.submissions.count,
      num_submitted_per_day: average_number_per_day(track.submissions, Submission)
    }
  end

  def average_number_per_day(query, model)
    total_count = query.where("#{model.table_name}.created_at >= ?", Time.current - NUM_DAYS_FOR_AVERAGE.days).count
    (total_count / NUM_DAYS_FOR_AVERAGE.to_f).ceil
  end

  NUM_DAYS_FOR_AVERAGE = 30
  private_constant :NUM_DAYS_FOR_AVERAGE
end
