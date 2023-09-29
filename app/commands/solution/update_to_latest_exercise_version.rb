class Solution::UpdateToLatestExerciseVersion
  include Mandate

  initialize_with :solution

  def call
    solution.update!(
      git_slug: exercise.slug,
      git_sha: exercise.git_sha,
      git_important_files_hash: exercise.git_important_files_hash
    )

    # Only bother with these if we have a submission
    # but definitely do them before running the bit below
    if submission
      update_latest_iteration!
      rerun_tests!
      rerun_submission_representation!
    end

    # Changing this data changes which submission_representation is active
    # so we need to recalculate the correct exercise representation as a result.
    # This might be unncessarily if the solution isn't published, but we let the
    # job deal with that downstream.
    #
    # We wait a few seconds just in case this is called in a transaction (e.g. in a bulk job).
    Solution::UpdatePublishedExerciseRepresentation.defer(solution, wait: 10)
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
    # (reload as submission's test run will be cached to nil)
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
    # (reload as submission's test run will be cached to nil)
    if submission.reload_submission_representation
      Submission::SyncRepresentationStatus.(submission)
    else
      Submission::Representation::Init.(submission, run_in_background: true)
    end
  end

  memoize
  def submission = solution.latest_iteration&.submission

  delegate :exercise, to: :solution
end
