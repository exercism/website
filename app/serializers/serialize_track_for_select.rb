class SerializeTrackForSelect
  include Mandate

  ALL_TRACK = {
    slug: nil,
    title: "All Tracks",
    icon_url: nil
  }.freeze

  initialize_with :track

  def call
    {
      slug: track.slug,
      title: track.title,
      icon_url: track.icon_url
    }
  end
end
