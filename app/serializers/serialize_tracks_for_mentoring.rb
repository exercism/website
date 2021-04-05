class SerializeTracksForMentoring
  include Mandate

  def initialize(tracks, mentor: nil)
    @tracks = tracks
    @mentor = mentor
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
  attr_reader :tracks, :mentor

  memoize
  def request_counts
    Mentor::Request::Retrieve.(
      mentor: mentor,
      sorted: false, paginated: false
    ).joins(solution: :exercise).
      group('exercises.track_id').
      count
  end
end
