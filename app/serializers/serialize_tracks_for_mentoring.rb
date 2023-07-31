class SerializeTracksForMentoring
  include Mandate

  initialize_with :tracks, :mentor

  def call
    tracks.order(title: :asc).map do |track|
      serialize_track(track)
    end
  end

  def serialize_track(track)
    {
      slug: track.slug,
      title: track.title,
      icon_url: track.icon_url,
      num_solutions_queued: request_counts[track.id].to_i,
      median_wait_time: track.median_wait_time,
      links: {
        exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: track.slug)
      }
    }
  end

  private
  memoize
  def request_counts
    mentor ? request_counts_with_mentor : request_counts_without_mentor
  end

  def request_counts_with_mentor
    ::Mentor::Request::Retrieve.(
      mentor:,
      limit_tracks: false,
      sorted: false,
      paginated: false
    ).
      where(track_id: tracks).
      group(:track_id).count
  end

  # We don't acutally care about what tracks the person
  # mentors when we serialize here. We're going to seraialize
  # all the tracks that have been passed in. However we do
  # care about excluding your own solutions, etc.
  def request_counts_without_mentor
    Mentor::Request.
      pending.
      where(track_id: tracks).
      group(:track_id).count
  end
end
