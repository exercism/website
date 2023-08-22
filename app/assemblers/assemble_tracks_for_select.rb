class AssembleTracksForSelect
  include Mandate

  def initialize(tracks = default_tracks)
    @tracks = tracks
  end

  def call
    [
      SerializeTrackForSelect::ALL_TRACK,

      # Don't use order here - it slows things down. Just sort in Ruby intead
      *tracks.sort_by(&:title).map { |track| SerializeTrackForSelect.(track) }
    ]
  end

  private
  attr_reader :tracks

  def default_tracks = ::Track.active
end
