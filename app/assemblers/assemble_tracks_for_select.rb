class AssembleTracksForSelect
  include Mandate

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
  def data_for_track(track)
    {
      id: track.slug,
      title: track.title,
      icon_url: track.icon_url
    }
  end

  def tracks
    ::Track.active
  end
end
