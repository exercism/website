class AssembleTrackSwitcher
  include Mandate

  def call
    {
      tracks: [
        {
          id: nil,
          title: "All",
          icon_url: "ICON"
        }
      ].concat(tracks.map { |track| data_for_track(track) })
    }
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
