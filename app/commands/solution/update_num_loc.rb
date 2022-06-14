class Solution
  class UpdateNumLoc
    include Mandate

    initialize_with :solution

    def call = solution.update!(num_loc:)

    private
    def num_loc
      iteration = solution.latest_published_iteration || solution.latest_iteration
      iteration&.num_loc.to_i
    end
  end
end
