class AssembleTracksForSelect
  include Mandate

  def self.format(track)
    if track == :all
      return({
        id: nil,
        title: "All Tracks",
        icon_url: "ICON"
      })
    end

    {
      id: track.slug,
      title: track.title,
      icon_url: track.icon_url
    }
  end

  def initialize(tracks = default_tracks)
    @tracks = tracks
  end

  def call
    [
      AssembleTracksForSelect.format(:all),
      tracks.map { |track| self.class.format(track) }
    ].flatten
  end

  private
  attr_reader :tracks

  def default_tracks
    ::Track.active
  end
end
