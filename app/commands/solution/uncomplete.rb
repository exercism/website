class Solution
  class Uncomplete
    include Mandate

    initialize_with :solution

    def call
      solution.update!(completed_at: nil)
      Solution::Unpublish.(solution)
    end
  end
end
