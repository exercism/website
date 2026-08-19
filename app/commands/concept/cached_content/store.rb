# Generates a concept's parsed content and writes it to the S3 cache.
# Deferred from Retrieve on a cache miss so the write (and the repeat
# generation it needs) happens off the request path.
class Concept::CachedContent::Store
  include Mandate

  queue_as :background

  initialize_with :concept

  def call
    S3Cache::Write.(cache_key, Concept::CachedContent::Generate.(concept))
  end

  private
  # Must match Concept::CachedContent::Retrieve#cache_key
  def cache_key
    uuid = concept.uuid
    "concept-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{concept.synced_to_git_sha}.json"
  end
end
