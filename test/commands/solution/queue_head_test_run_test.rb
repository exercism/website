require "test_helper"

class Solution::QueueHeadTestRunTest < ActiveSupport::TestCase
  test "published: inits test run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  %i[not_queued exceptioned].each do |status|
    test "published: updates status and exits if there's a good head run and but old #{status} status" do
      solution = create :practice_solution, :published, published_iteration_head_tests_status: status
      submission = create :submission, solution: solution
      create :iteration, submission: submission, solution: solution
      create :submission_test_run, submission: submission

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.published_iteration_head_tests_status
    end
  end

  %i[passed failed errored].each do |status|
    test "published: does not init if there's a head run and status is #{status}" do
      solution = create :practice_solution, :published, published_iteration_head_tests_status: status
      submission = create :submission, solution: solution
      create :iteration, submission: submission, solution: solution
      create :submission_test_run, submission: submission

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.published_iteration_head_tests_status
    end
  end

  test "published: inits if there's an exceptioned head run even if passed" do
    solution = create :practice_solution, :published, published_iteration_head_tests_status: :passed
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission, ops_status: 405

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: does not init if there's no test runner" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    solution.exercise.expects(:has_test_runner?).returns(false).twice

    Submission::TestRun::Init.expects(:call).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: inits if there's not a head run" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission, git_important_files_hash: "foobar"

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: writes to efs if not already written" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :submission_file, submission: submission
    create :iteration, submission: submission, solution: solution

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.rm_rf(dir) if Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!)

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: does not write to efs if dir exists" do
    solution = create :practice_solution, :published
    submission = create :submission, solution: solution
    create :submission_file, submission: submission
    create :iteration, submission: submission, solution: solution

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.mkdir(dir) unless Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: inits test run" do
    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  %i[not_queued exceptioned].each do |status|
    test "latest: updates status and exits if there's a good head run and but old #{status} status" do
      solution = create :practice_solution, latest_iteration_head_tests_status: status
      submission = create :submission, solution: solution
      create :iteration, submission: submission, solution: solution
      create :submission_test_run, submission: submission

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    end
  end

  %i[passed failed errored].each do |status|
    test "latest: does not init if there's a head run and status is #{status}" do
      solution = create :practice_solution, latest_iteration_head_tests_status: status
      submission = create :submission, solution: solution
      create :iteration, submission: submission, solution: solution
      create :submission_test_run, submission: submission

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    end
  end

  test "latest: inits if there's an exceptioned head run even if passed" do
    solution = create :practice_solution, latest_iteration_head_tests_status: :passed
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission, ops_status: 405

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: does not init if there's no test runner" do
    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    solution.exercise.expects(:has_test_runner?).returns(false)

    Submission::TestRun::Init.expects(:call).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: inits if there's not a head run" do
    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :iteration, submission: submission, solution: solution
    create :submission_test_run, submission: submission, git_important_files_hash: "foobar"

    Submission::TestRun::Init.expects(:call).with(
      submission, type: :solution, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: writes to efs if not already written" do
    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission
    create :iteration, submission: submission, solution: solution

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.rm_rf(dir) if Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!)

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: does not write to efs if dir exists" do
    solution = create :practice_solution
    submission = create :submission, solution: solution
    create :submission_file, submission: submission
    create :iteration, submission: submission, solution: solution

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.mkdir(dir) unless Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "published and latest: inits two test run" do
    solution = create :practice_solution, :published
    published_submission = create :submission, solution: solution
    published_iteration = create :iteration, submission: published_submission, solution: solution
    solution.update(published_iteration: published_iteration)
    latest_submission = create :submission, solution: solution
    create :iteration, submission: latest_submission, solution: solution
    create :iteration, solution: solution, deleted_at: Time.current

    Submission::TestRun::Init.expects(:call).with(
      published_submission, type: :solution, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Submission::TestRun::Init.expects(:call).with(
      latest_submission, type: :solution, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end
end
