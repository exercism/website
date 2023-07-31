require "test_helper"

class Solution::QueueHeadTestRunTest < ActiveSupport::TestCase
  test "published: inits test run" do
    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)

    Submission::TestRun::Init.expects(:call).with(
      submission, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  %i[not_queued exceptioned].each do |status|
    test "published: updates status and exits if there's a good head run and but old #{status} status" do
      solution = create :practice_solution, :published, published_iteration_head_tests_status: status
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)
      create(:submission_test_run, submission:)

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.published_iteration_head_tests_status
    end
  end

  %i[passed failed errored].each do |status|
    test "published: does not init if there's a head run and status is #{status}" do
      solution = create :practice_solution, :published, published_iteration_head_tests_status: status
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)
      create(:submission_test_run, submission:)

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.published_iteration_head_tests_status
    end
  end

  test "published: inits if there's an exceptioned head run even if passed" do
    solution = create :practice_solution, :published, published_iteration_head_tests_status: :passed
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)
    create :submission_test_run, submission:, ops_status: 405

    Submission::TestRun::Init.expects(:call).with(
      submission, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: does not init if there's no test runner" do
    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)
    solution.exercise.expects(:has_test_runner?).returns(false).twice

    Submission::TestRun::Init.expects(:call).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: inits if there's not a head run" do
    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)
    create :submission_test_run, submission:, git_important_files_hash: "foobar"

    Submission::TestRun::Init.expects(:call).with(
      submission, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "published/latest: does not init if tests are already running" do
    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)
    submission.update!(tests_status: :queued)

    Submission::TestRun::Init.expects(:call).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: writes to efs if not already written" do
    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:submission_file, submission:)
    create(:iteration, submission:, solution:)

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.rm_rf(dir) if Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!)

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: does not write to efs if dir exists" do
    solution = create :practice_solution, :published
    submission = create(:submission, solution:)
    create(:submission_file, submission:)
    create(:iteration, submission:, solution:)

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.mkdir(dir) unless Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "published: set status to exceptioned when exercise files are not found" do
    exercise = create :practice_exercise, slug: 'unknown'
    solution = create(:practice_solution, :published, exercise:)
    submission_1 = create(:submission, solution:)
    iteration_1 = create(:iteration, submission: submission_1, solution:)
    submission_2 = create(:submission, solution:)
    create(:iteration, submission: submission_2, solution:)
    solution.update!(published_iteration: iteration_1)

    Solution::QueueHeadTestRun.(solution)

    assert_equal :exceptioned, solution.reload.published_iteration_head_tests_status
  end

  test "latest: inits test run" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)

    Submission::TestRun::Init.expects(:call).with(
      submission, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  %i[not_queued exceptioned].each do |status|
    test "latest: updates status and exits if there's a good head run and but old #{status} status" do
      solution = create :practice_solution, latest_iteration_head_tests_status: status
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)
      create(:submission_test_run, submission:)

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    end
  end

  %i[passed failed errored].each do |status|
    test "latest: does not init if there's a head run and status is #{status}" do
      solution = create :practice_solution, latest_iteration_head_tests_status: status
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)
      create(:submission_test_run, submission:)

      Submission::TestRun::Init.expects(:call).never

      Solution::QueueHeadTestRun.(solution)

      assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    end
  end

  test "latest: inits if there's an exceptioned head run even if passed" do
    solution = create :practice_solution, latest_iteration_head_tests_status: :passed
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)
    create :submission_test_run, submission:, ops_status: 405

    Submission::TestRun::Init.expects(:call).with(
      submission, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: does not init if there's no test runner" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)
    solution.exercise.expects(:has_test_runner?).returns(false)

    Submission::TestRun::Init.expects(:call).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: inits if there's not a head run" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)
    create :submission_test_run, submission:, git_important_files_hash: "foobar"

    Submission::TestRun::Init.expects(:call).with(
      submission, git_sha: submission.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: writes to efs if not already written" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:submission_file, submission:)
    create(:iteration, submission:, solution:)

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.rm_rf(dir) if Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!)

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: does not write to efs if dir exists" do
    solution = create :practice_solution
    submission = create(:submission, solution:)
    create(:submission_file, submission:)
    create(:iteration, submission:, solution:)

    dir = [Exercism.config.efs_submissions_mount_point, submission.uuid].join('/')
    FileUtils.mkdir(dir) unless Dir.exist?(dir)

    Submission::File.any_instance.expects(:write_to_efs!).never

    Solution::QueueHeadTestRun.(solution)
  end

  test "latest: set status to exceptioned when exercise files are not found" do
    exercise = create :practice_exercise, slug: 'unknown'
    solution = create(:practice_solution, exercise:)
    submission = create(:submission, solution:)
    create(:iteration, submission:, solution:)

    Solution::QueueHeadTestRun.(solution)

    assert_equal :exceptioned, solution.reload.latest_iteration_head_tests_status
  end

  test "published and latest: inits two test run" do
    solution = create :practice_solution, :published
    published_submission = create(:submission, solution:)
    published_iteration = create(:iteration, submission: published_submission, solution:)
    solution.update(published_iteration:)
    latest_submission = create(:submission, solution:)
    create(:iteration, submission: latest_submission, solution:)
    create :iteration, solution:, deleted_at: Time.current

    Submission::TestRun::Init.expects(:call).with(
      published_submission, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Submission::TestRun::Init.expects(:call).with(
      latest_submission, git_sha: solution.exercise.git_sha, run_in_background: true
    )

    Solution::QueueHeadTestRun.(solution)
  end
end
