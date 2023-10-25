class Solution::UpdateNumLoc
  include Mandate

  initialize_with :solution

  def call
    return if num_loc == solution.num_loc

    solution.update!(num_loc:)
  end

  private
  memoize
  def num_loc
    iteration = solution.latest_published_iteration || solution.latest_iteration
    iteration&.num_loc.to_i
  end
end
