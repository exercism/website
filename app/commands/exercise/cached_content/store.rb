# Generates an exercise's parsed content and writes it to the S3 cache.
# Deferred from Retrieve on a cache miss so the write (and the repeat
# generation it needs) happens off the request path.
class Exercise::CachedContent::Store
  include Mandate

  queue_as :background

  initialize_with :exercise, :solution

  def call
    S3Cache::Write.(cache_key, Exercise::CachedContent::Generate.(exercise, solution))
  end

  private
  # Must match Exercise::CachedContent::Retrieve#cache_key
  def cache_key
    uuid = exercise.uuid
    sha = solution ? solution.git_sha : exercise.git_sha
    "exercise-content/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{sha}.json"
  end
end
