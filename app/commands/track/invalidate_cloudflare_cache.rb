class Track::InvalidateCloudflareCache
  include Mandate

  queue_as :background

  initialize_with :track

  def call
    Cloudflare::PurgeUrls.(urls)
  end

  private
  # These are the track-level pages that are cached at the edge for a day.
  # The tracks index is included because a track changing its title, blurb or
  # active status changes how it appears in that list.
  def urls
    [
      Exercism::Routes.track_url(track),
      Exercism::Routes.track_exercises_url(track),
      Exercism::Routes.track_concepts_url(track),
      Exercism::Routes.track_build_url(track),
      Exercism::Routes.tracks_url
    ]
  end
end
