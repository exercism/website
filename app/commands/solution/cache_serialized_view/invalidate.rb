# Deletes all cached solution-view payloads for a solution.
# Belt-and-braces: keys are versioned with updated_at so a missed delete
# never serves stale data. The prefix includes the shard segments so it
# targets exactly this solution's objects.
class Solution::CacheSerializedView::Invalidate
  include Mandate

  queue_as :background

  initialize_with :solution

  def call
    S3Cache::DeletePrefix.(prefix)
  end

  private
  def prefix
    uuid = solution.uuid
    "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/"
  end
end
