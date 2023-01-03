class Solution::UpdateToLatestExerciseVersion
  include Mandate

  initialize_with :solution

  def call
    solution.sync_git!
    update_latest_iteration!
  end

  # This updates the submission of the latest iteration
  # by setting its git_sha and then rerunning the tests.
  # This then updates the status of both the solution and
  # the submission to the result of this latest run.
  def update_latest_iteration!
    submission = solution.latest_iteration&.submission
    return unless submission

    submission.update!(git_sha: solution.git_sha, git_slug: solution.git_slug)

    # We run this in submission mode (the default) so as to set the last
    # iteration to look like it's reprocessing in the UI.
    Submission::TestRun::Init.(submission, run_in_background: true) if solution.exercise.has_test_runner?
  end
end
