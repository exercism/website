# Retrieves a concept's parsed about and introduction documents from S3,
# falling back to generating them live on a miss (and lazily filling the
# cache off the request path). Any S3 failure also falls back to live
# generation, so this can never raise to the user because of the cache.
#
# Keys are versioned with synced_to_git_sha, so there is nothing to
# invalidate: a sync moves the concept onto a new key. Unlike an
# exercise, a concept has no sha of its own and reads its documents at
# the repository's HEAD, so this key turns over on every track sync
# rather than only when the concept's own content changes. That costs a
# regeneration per concept per sync, which is negligible against the
# reads it saves in between.
#
# The uuid is sharded into the key to avoid hot S3 prefixes (uuids are
# compact hex, so their leading characters are uniformly distributed).
class Concept::CachedContent::Retrieve
  include Mandate

  initialize_with :concept

  def call
    cached || generate!
  end

  private
  def cached = S3Cache::Read.(cache_key)

  def generate!
    Concept::CachedContent::Generate.(concept).tap do
      Concept::CachedContent::Store.defer(concept)
    end
  end

  def cache_key
    uuid = concept.uuid
    "concept-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{concept.synced_to_git_sha}.json"
  end
end
