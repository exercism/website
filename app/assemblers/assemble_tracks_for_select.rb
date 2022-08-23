class AssembleTracksForSelect
  include Mandate

  initialize_with tracks: ::Track.active

  def call
    [
      SerializeTrackForSelect::ALL_TRACK,
      *tracks.order(title: :asc).map { |track| SerializeTrackForSelect.(track) }
    ]
  end
end
