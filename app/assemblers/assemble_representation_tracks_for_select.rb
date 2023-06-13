class AssembleRepresentationTracksForSelect
  include Mandate

  initialize_with :mentor, mode: Mandate::NO_DEFAULT

  def call
    tracks.map do |track|
      SerializeTrackForSelect.(track).merge(num_submissions: track_num_representations[track.id])
    end
  end

  private
  memoize
  def tracks = supermentored_tracks.select { |track| track_num_representations.key?(track.id) }

  memoize
  def supermentored_tracks
    return Track.all if mentor.staff?

    Track.where(id: mentor.track_mentorships.supermentor_frequency.select(:track_id)).order(title: :asc)
  end

  memoize
  def track_num_representations
    Exercise::Representation::Search.(mentor:, mode:, sorted: false, paginated: false,
      track: supermentored_tracks).
      group(:track_id).
      count
  end
end
