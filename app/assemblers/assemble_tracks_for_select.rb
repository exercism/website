class AssembleTracksForSelect
  include Mandate

  def initialize(tracks = default_tracks)
    @tracks = tracks
  end

  def call
    [
      SerializeTrackForSelect::ALL_TRACK,
      *tracks.order(title: :asc).map { |track| SerializeTrackForSelect.(track) }
    ]
  end

  private
  attr_reader :tracks

  def default_tracks = ::Track.active
end
