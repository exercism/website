# This syncs solution.published_iteration_head_tests_status to be
# the same as the solution's actual published_iteration status
class Solution::SyncPublishedIterationHeadTestsStatus
  include Mandate

  initialize_with :solution

  def call
    return false unless test_run

    if test_run.ops_errored?
      status = :exceptioned
    elsif test_run.passed?
      status = :passed
    elsif test_run.failed?
      status = :failed
    else
      status = :errored
    end

    return true if solution.published_iteration_head_tests_status == status

    Solution::UpdatePublishedIterationHeadTestsStatus.(solution, status)

    true
  end

  memoize
  def test_run
    solution.latest_published_iteration_submission&.head_test_run
  end
end
