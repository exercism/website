# This queues a test-run for the latest published
# iteration. By default it does not queue it if
# the previous version passed, error or failed the tests.
class Solution::QueueHeadTestRun
  include Mandate

  queue_as :background

  initialize_with :solution, force: false

  def call
    handle_latest!
    handle_latest_published!
  end

  private
  delegate :exercise, to: :solution

  def handle_latest!
    return unless latest_submission

    # Get out of here if:
    # - we don't want to force run things
    # - and the current head sync works fine
    # - and the previous version didn't exception
    return if !force &&
              Solution::SyncLatestIterationHeadTestsStatus.(solution) &&
              !solution.latest_iteration_head_tests_status_exceptioned?

    # If we don't have a test runner then we shouldn't run anything so get out of here
    return solution.update_latest_iteration_head_tests_status!(:not_queued) unless exercise.has_test_runner?

    begin
      process_submission!(latest_submission)
    rescue Rugged::TreeError
      solution.update_latest_iteration_head_tests_status!(:exceptioned)
    end
  end

  def handle_latest_published!
    return unless latest_published_submission

    # Get out of here if:
    # - we don't want to force run things
    # - and the current head sync works fine
    # - and the previous version didn't exception
    return if !force &&
              Solution::SyncPublishedIterationHeadTestsStatus.(solution) &&
              !solution.published_iteration_head_tests_status_exceptioned?

    # If we don't have a test runner then we shouldn't run anything so get out of here
    return solution.update_published_iteration_head_tests_status!(:not_queued) unless exercise.has_test_runner?

    # We don't want to generate two test runs, so we exit before that
    # happens. All the stuff above should happen even if they're the
    # same solution, as that guarantees statuses are updated correctly.
    return if latest_published_submission == latest_submission

    begin
      process_submission!(latest_published_submission)
    rescue Rugged::TreeError
      solution.update_published_iteration_head_tests_status!(:exceptioned)
    end
  end

  def process_submission!(submission)
    # Legacy solutions may never have been pushed to EFS, so check that here.
    submission.write_to_efs!

    Submission::TestRun::Init.(
      submission,
      git_sha: exercise.git_sha,
      run_in_background: true
    )
  end

  memoize
  def latest_submission
    solution.latest_iteration_submission
  end

  memoize
  def latest_published_submission
    solution.latest_published_iteration_submission
  end
end
