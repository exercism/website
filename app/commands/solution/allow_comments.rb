class Solution::AllowComments
  include Mandate

  initialize_with :solution

  def call
    solution.update!(allow_comments: true)
    Solution::InvalidateCloudflareCache.defer(solution)
  end
end
