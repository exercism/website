class Solution::UpdateToLatestExerciseVersion
  include Mandate

  initialize_with :solution

  def call
    solution.sync_git!

    return unless submission

    update_latest_iteration!
    rerun_tests!
    rerun_submission_representation!
  end

  # This updates the submission of the latest iteration
  # by setting its git_sha and then rerunning the tests.
  # This then updates the status of both the solution and
  # the submission to the result of this latest run.
  def update_latest_iteration!
    submission.update!(
      git_sha: solution.git_sha,
      git_slug: solution.git_slug,
      git_important_files_hash: solution.git_important_files_hash,
      exercise_representer_version: solution.exercise.representer_version
    )
  end

  # We run this in submission mode (the default) so as to set the last
  # iteration to look like it's reprocessing in the UI.
  def rerun_tests!
    # We might have already run this when running the head test run
    # If we do, then sync the status to it
    # (reload as submission's test run will be cached)
    if submission.reload_test_run
      Submission::SyncTestsStatus.(submission)
    else
      Submission::TestRun::Init.(submission, run_in_background: true)
    end
  end

  def rerun_submission_representation!
    return unless solution.exercise.has_representer?

    # We might have already run this when running the head test run
    # If we do, then sync the status to it
    # (reload as submission's test run will be cached)
    if submission.reload_submission_representation
      Submission::SyncTestsStatus.(submission)
    else
      Submission::Representation::Init.(submission, run_in_background: true)
    end
  end

  memoize
  def submission = solution.latest_iteration&.submission
end
