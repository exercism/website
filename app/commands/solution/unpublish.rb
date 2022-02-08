class Solution
  class Unpublish
    include Mandate

    initialize_with :solution

    def call
      solution.update!(published_iteration_id: nil, published_at: nil)
    end
  end
end
