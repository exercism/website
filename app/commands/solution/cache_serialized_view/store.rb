# Generates the solution-view payload and writes it to the S3 cache.
# Deferred from Retrieve on a cache miss so the write (and the repeat
# generation it needs) happens off the request path.
class Solution::CacheSerializedView::Store
  include Mandate

  queue_as :background

  initialize_with :solution

  def call
    S3Cache::Write.(cache_key, Solution::CacheSerializedView::Generate.(solution))
  end

  private
  # Must match Solution::CacheSerializedView::Retrieve#cache_key
  def cache_key
    uuid = solution.uuid
    "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{solution.updated_at.to_i}.json"
  end
end
