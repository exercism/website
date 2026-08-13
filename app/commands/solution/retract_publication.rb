# TODO: This bypasses Solution::Unpublish entirely, and so skips tags,
# representation recache, snippet, num_loc and the exercise counter.
# That's a pre-existing bug, deliberately not fixed here.
class Solution::RetractPublication
  include Mandate

  initialize_with :solution

  def call
    solution.update!(published_at: nil, published_iteration_id: nil)
    Solution::InvalidateCloudflareCache.defer(solution)
  end
end
