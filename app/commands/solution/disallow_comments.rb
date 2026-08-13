class Solution::DisallowComments
  include Mandate

  initialize_with :solution

  def call
    solution.update!(allow_comments: false)
    Solution::InvalidateCloudflareCache.defer(solution)
  end
end
