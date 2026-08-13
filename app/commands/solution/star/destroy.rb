class Solution::Star::Destroy
  include Mandate

  initialize_with :solution, :user

  def call
    solution.stars.where(user:).destroy_all
    Solution::InvalidateCloudflareCache.defer(solution)
  end
end
