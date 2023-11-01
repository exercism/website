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

    # Always call this as it also updates the git_sha
    # and git_important_files_hash
    Solution::UpdateLatestIterationHeadTestsStatus.(solution, status)

    Solution::AutoUpdateToLatestExerciseVersion.(solution)

    true
  end

  memoize
  def test_run
    solution.latest_iteration_submission&.head_test_run
  end
end
