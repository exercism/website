class Solution::UpdatePublishedIterationHeadTestsStatus
  include Mandate

  initialize_with :solution, :status

  def call
    return if solution.published_iteration_head_tests_status == status.to_sym

    solution.update_column(:published_iteration_head_tests_status, status)

    Solution::SyncToSearchIndex.defer(solution)
    Solution::UpdateTags.defer(solution)
  end
end
