# Deletes all cached solution-view payloads for a solution.
# Belt-and-braces: keys are versioned with updated_at so a missed delete
# never serves stale data. The prefix includes the shard segments so it
# targets exactly this solution's objects.
class Solution::CachedSerializedView::Invalidate
  include Mandate

  queue_as :background

  initialize_with :solution

  # By the time this runs (deferred), solution.updated_at is the new
  # version, so the current key is excluded from the delete. Otherwise
  # this could race a concurrent Store and delete the entry that was
  # just written for the new version.
  def call
    S3Cache::DeletePrefix.(prefix, except_key: current_key)
  end

  private
  def prefix
    uuid = solution.uuid
    "solution-view/#{uuid[0, 2]}/#{uuid[2, 2]}/#{uuid}/"
  end

  def current_key = "#{prefix}#{solution.updated_at.to_i}.json"
end
