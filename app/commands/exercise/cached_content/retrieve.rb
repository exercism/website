# Retrieves an exercise's parsed introduction and instructions from S3,
# falling back to generating them live on a miss (and lazily filling the
# cache off the request path). Any S3 failure also falls back to live
# generation, so this can never raise to the user because of the cache.
#
# Keys are versioned with the git sha the content is read at, which makes
# the cached content immutable: a sync that changes an exercise changes
# its sha and therefore its key, so there is nothing to invalidate. Old
# shas are left behind as orphans rather than being swept, as a solution
# pinned to one may still be rendered at any time.
#
# The sha is the one we actually read from, so anonymous visitors and
# solutions that are up to date share a single entry, and only
# out-of-date solutions get objects of their own.
#
# The uuid is sharded into the key to avoid hot S3 prefixes (uuids are
# compact hex, so their leading characters are uniformly distributed).
class Exercise::CachedContent::Retrieve
  include Mandate

  initialize_with :exercise, :solution

  def call
    cached || generate!
  end

  private
  def cached = S3Cache::Read.(cache_key)

  def generate!
    Exercise::CachedContent::Generate.(exercise, solution).tap do
      Exercise::CachedContent::Store.defer(exercise, solution)
    end
  end

  def cache_key
    uuid = exercise.uuid
    sha = solution ? solution.git_sha : exercise.git_sha
    "exercise-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{sha}.json"
  end
end
