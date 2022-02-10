# This queues a test-run for the latest published
# iteration. By default it does not queue it if
# the previous version passed, error or failed the tests.
class Solution::QueueHeadTestRun
  include Mandate

  def initialize(solution, force: false)
    @solution = solution
    @force = force
  end

  def call
    # Get out of here if:
    # - we don't want to force run things
    # - and the current head sync works fine
    # - and the previous version didn't exception
    return if !force &&
              Solution::SyncPublishedIterationHeadTestsStatus.(solution) &&
              !solution.published_iteration_head_tests_status_exceptioned?
    return unless submission

    unless solution.exercise.has_test_runner?
      solution.update_published_iteration_head_tests_status!(:not_queued)
      return
    end

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
