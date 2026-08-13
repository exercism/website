class Solution::Star::Create
  include Mandate

  initialize_with :solution, :user

  def call
    solution.stars.create_or_find_by!(user:).tap do
      Solution::InvalidateCloudflareCache.defer(solution)
    end
  end
end
