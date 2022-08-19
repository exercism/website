class AssembleRepresentationTracksForSelect
  include Mandate

  initialize_with :user, :status

  def call
    [
      SerializeTrackForSelect::ALL_TRACK.merge(num_submissions: track_counts.values.sum),
      *tracks.map { |track| SerializeTrackForSelect.(track).merge(num_submissions: track_counts[track.id]) }
    ]
  end

  private
  memoize
  def track_counts = representations.group(:track_id).count

  memoize
  def tracks = Track.where(id: track_counts.keys).order(title: :asc)

  memoize
  def representations
    Exercise::Representation::Search.(user:, status:, sorted: false, paginated: false)
  end
end
