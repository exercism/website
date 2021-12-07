class Solution::QueueHeadTestRun
  include Mandate

  def initialize(solution, force: false)
    @solution = solution
    @force = force
  end

  def call
    return unless submission
    return if submission.head_test_run&.ops_success? && !force

    write_efs!
    init_test_run!
  end

  private
  def write_efs!
    return if Dir.exist?([Exercism.config.efs_submissions_mount_point, submission.uuid].join('/'))

    submission.files.each(&:write_to_efs!)
  end

  def init_test_run!
    Submission::TestRun::Init.(
      submission,
      type: :solution,
      git_sha: exercise.git_sha,
      run_in_background: true
    )
  end

  memoize
  def submission
    solution.published_iterations.last&.submission
  end

  attr_reader :solution, :force

  delegate :exercise, to: :submission
end
