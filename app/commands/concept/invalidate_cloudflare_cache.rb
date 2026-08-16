class Concept::InvalidateCloudflareCache
  include Mandate

  queue_as :background

  initialize_with :concept

  def call
    Cloudflare::PurgeUrls.(urls)
  end

  private
  # A concept changing its name or blurb changes the concept map too, so the
  # track's concepts index gets purged alongside the concept page itself.
  def urls
    [
      Exercism::Routes.track_concept_url(concept.track, concept),
      Exercism::Routes.track_concepts_url(concept.track)
    ]
  end
end
