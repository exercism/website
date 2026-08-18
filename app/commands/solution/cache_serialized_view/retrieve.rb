# Retrieves the cached solution-view payload from S3, falling back to
# generating it live on a miss (and lazily filling the cache off the
# request path). Any S3 failure also falls back to live generation, so
# this can never raise to the user because of the cache.
#
# Keys are versioned with updated_at, so a stale entry is simply never
# read again after the solution changes. The uuid is sharded into the
# key to avoid hot S3 prefixes (uuids are compact hex, so their leading
# characters are uniformly distributed).
class Solution::CacheSerializedView::Retrieve
  include Mandate

  initialize_with :solution

  def call
    cached || generate!
  end

  private
  def cached = S3Cache::Read.(cache_key)

  def generate!
    Solution::CacheSerializedView::Generate.(solution).tap do
      Solution::CacheSerializedView::Store.defer(solution)
    end
  end

  def cache_key
    uuid = solution.uuid
    "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/#{solution.updated_at.to_i}.json"
  end
end
