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

    solution.update_published_iteration_head_tests_status!(status)

    true
  end

  memoize
  def test_run
    solution.published_iterations.last&.submission&.head_test_run
  end
end
