class Solution::UpdateLatestIterationHeadTestsStatus
  include Mandate

  initialize_with :solution, :status

  def call
    return if solution.latest_iteration_head_tests_status == status.to_sym

    solution.update_column(:latest_iteration_head_tests_status, status)
    Solution::SyncToSearchIndex.defer(solution)
  end
end
