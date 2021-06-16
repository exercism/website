class AssembleTracksForSelect
  include Mandate

  def initialize(tracks = default_tracks)
    @tracks = tracks
  end

  def call
    [
      {
        id: nil,
        title: "All Tracks",
        icon_url: "ICON"
      }
    ].concat(tracks.map { |track| data_for_track(track) })
  end

  private
  attr_reader :tracks

  def data_for_track(track)
    {
      id: track.slug,
      title: track.title,
      icon_url: track.icon_url
    }
  end

  def default_tracks
    ::Track.active
  end
end
