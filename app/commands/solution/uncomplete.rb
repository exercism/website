class Solution::Uncomplete
  include Mandate

  initialize_with :solution

  def call
    solution.transaction do
      solution.update!(completed_at: nil)
      Solution::Unpublish.(solution)
    end
  end
end
