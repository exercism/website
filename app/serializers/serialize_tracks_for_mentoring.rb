class SerializeTracksForMentoring
  include Mandate

  def initialize(tracks)
    @tracks = tracks
  end

  def call
    {
      tracks: tracks.order(title: :asc).map do |track|
        serialize_track(track)
      end
    }
  end

  def serialize_track(track)
    {
      id: track.slug,
      title: track.title,
      icon_url: track.icon_url,
      num_solutions_queued: request_counts[track.id].to_i,
      avg_wait_time: "2 days", # TODO
      links: {
        exercises: Exercism::Routes.exercises_api_mentoring_requests_url(track_slug: track.slug)
      }
    }
  end

  private
  attr_reader :tracks

  memoize
  def request_counts
    @requests = Mentor::Request.
      joins(solution: :exercise).
      pending.
      unlocked.
      where('exercises.track_id': tracks).
      group('exercises.track_id').count
  end
end
