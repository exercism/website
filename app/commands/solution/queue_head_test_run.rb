class Solution::QueueHeadTestRun
  include Mandate

  initialize_with :solution

  def call
    return unless submission
    return if submission.head_test_run

    Submission::TestRun::Init.(submission, type: :solution, git_sha: exercise.git_sha, run_in_background: true)
  end

  memoize
  def submission
    solution.published_iterations.last&.submission
  end

  memoize
  delegate :exercise, to: :submission
end
