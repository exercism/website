# This syncs solution.latest_iteration_head_tests_status to be
# the same as the solution's actual latest_iteration status
class Solution::SyncLatestIterationHeadTestsStatus
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

    # Only update it if we need to.
    unless solution.latest_iteration_head_tests_status == status # rubocop:disable Style/IfUnlessModifier
      solution.update_latest_iteration_head_tests_status!(status)
    end

    true
  end

  memoize
  def test_run
    solution.latest_iteration_submission&.head_test_run
  end
end
