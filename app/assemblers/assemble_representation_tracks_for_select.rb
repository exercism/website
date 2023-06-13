class AssembleRepresentationTracksForSelect
  include Mandate

  initialize_with :mentor, with_feedback: Mandate::NO_DEFAULT, is_admin: false

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
    num_representations_mentor = is_admin ? nil : mentor
    Exercise::Representation::Search.(mentor: num_representations_mentor, with_feedback:, sorted: false, paginated: false,
      track: supermentored_tracks).
      group(:track_id).
      count
  end
end
