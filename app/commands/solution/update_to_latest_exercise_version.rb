class Solution
  class UpdateToLatestExerciseVersion
    include Mandate

    initialize_with :solution

    def call
      solution.sync_git!
      update_latest_iteration!
    end

    # This updates the submission of the latest iteration
    # by setting its git_sha and then rerunning the tests
    # in solution mode, which leads the status of the solution
    # being set to the result of this latest run.
    def update_latest_iteration!
      submission = solution.latest_iteration&.submission
      return unless submission

      submission.update!(git_sha: solution.git_sha, git_slug: solution.git_slug)
      Submission::TestRun::Init.(submission, type: :solution)
    end
  end
end
