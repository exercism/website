class Solution::QueueHeadTestRun
  include Mandate

  def initialize(solution, force: false)
    @solution = solution
    @force = force
  end

  def call
    return unless submission
    return if submission.head_test_run && !force

    submission.files.each(&:write_to_efs!) unless Dir.exist?(Exercism.config.efs_submissions_mount_point, submission.uuid)

    Submission::TestRun::Init.(submission, type: :solution, git_sha: exercise.git_sha, run_in_background: true)
  end

  memoize
  def submission
    solution.published_iterations.last&.submission
  end

  attr_reader :solution, :force

  delegate :exercise, to: :submission
end
