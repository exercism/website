require "test_helper"

class Solution::QueueHeadTestRunTest < ActiveSupport::TestCase
  test "inits test run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "does not inits if there's a head run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission

    Submission::TestRun::Init.expects(:call).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "inits if there's an exceptioned head run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission, ops_status: 405

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "inits if there's not a head run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission, git_important_files_hash: "foobar"

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "writes to efs if not already written" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :submission_file, submission: submission
    create :iteration, submission: submission, solution: solution

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.rm_rf(dir) if Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!)

    Solution::QueueHeadTestRun.(solution)
  end

  test "does not write to efs if dir exists" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :submission_file, submission: submission
    create :iteration, submission: submission, solution: solution

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.mkdir(dir) unless Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!).never

    Solution::QueueHeadTestRun.(solution)
  end
end
