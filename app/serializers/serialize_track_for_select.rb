class SerializeTrackForSelect
  include Mandate

  ALL_TRACK = {
    id: nil,
    title: "All Tracks",
    icon_url: "ICON"
  }.freeze

  initialize_with :track

  def call
    {
      id: track.slug,
      title: track.title,
      icon_url: track.icon_url
    }
  end
end
