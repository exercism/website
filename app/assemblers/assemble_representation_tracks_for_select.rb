class AssembleRepresentationTracksForSelect
  include Mandate

  initialize_with :mentor, with_feedback: Mandate::NO_DEFAULT

  def call
    tracks.map do |track|
      SerializeTrackForSelect.(track).merge(num_submissions: track_num_representations[track.id])
    end
  end

  private
  memoize
  def tracks
    Track.where(id: track_ids_with_representation).
      where(id: track_ids_with_supermentor_privilege).
      order(title: :asc)
  end

  def track_ids_with_representation = track_num_representations.keys

  def track_ids_with_supermentor_privilege
    mentor.track_mentorships.supermentor.select(:track_id)
  end

  memoize
  def track_num_representations = representations.group(:track_id).count

  memoize
  def representations
    Exercise::Representation::Search.(mentor:, with_feedback:, sorted: false, paginated: false)
  end
end
