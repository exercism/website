class AssembleRepresentationTracksForAdminSelect
  include Mandate

  initialize_with with_feedback: Mandate::NO_DEFAULT

  def call
    tracks.map do |track|
      SerializeTrackForSelect.(track).merge(num_submissions: track_num_representations[track.id])
    end
  end

  private
  memoize
  def tracks = tracks_with_representation.select { |track| track_num_representations.key?(track.id) }

  memoize
  def tracks_with_representation = Track.where(id: Exercise::Representation.distinct.pluck(:track_id)).order(title: :asc)

  memoize
  def track_num_representations
    Exercise::Representation::Search.(mentor: nil, with_feedback:, sorted: false, paginated: false, track: tracks_with_representation).
      group(:track_id).
      count
  end
end
