require 'test_helper'

class Submission::TestRun::ProcessTest < ActiveSupport::TestCase
  test "should not do anything if the test run is not pending" do
    submission = create :submission
    job = create_test_runner_job!(submission, execution_status: 200, results: {})

    submission.tests_cancelled!
    Submission::TestRun::Process.(job)

    assert submission.reload.tests_cancelled?
    assert_equal :cancelled, submission.test_run.status
  end

  test "creates test_run record" do
    submission = create :submission
    ops_status = 201
    status = "foobar"
    message = "some barfoo message"
    version = 5
    tests = [{ 'foo' => 'bar' }]
    results = { 'version' => version, 'status' => status, 'message' => message, 'tests' => tests }
    job = create_test_runner_job!(submission, execution_status: ops_status, results:)

    Submission::TestRun::Process.(job)

    tr = submission.reload.test_run

    assert_equal ops_status, tr.ops_status
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal version, tr.version
    assert_equal results, tr.send(:raw_results)
  end

  test "handle ops error" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 500, results:)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_exceptioned?
  end

  test "handle tests pass" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_passed?
  end

  test "handle tests fail" do
    submission = create :submission
    results = { 'status' => 'fail', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:)

    # Cancel representation and analysis
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :analyzer)
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :representer)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_failed?
  end

  test "handle tests error" do
    submission = create :submission
    results = { 'status' => 'error', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:)

    # Cancel representation and analysis
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :analyzer)
    ToolingJob::Cancel.expects(:call).with(submission.uuid, :representer)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_errored?
  end

  test "handle bad status" do
    submission = create :submission
    results = { 'status' => 'oops', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_exceptioned?
  end

  test "doesn't update status for wrong git_sha" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:,
      git_sha: 'ae1a56deb0941ac53da22084af8eb6107d4b5c3a')

    assert submission.reload.tests_not_queued? # Sanity

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_not_queued?
  end

  test "broadcast without iteration" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:)

    SubmissionChannel.expects(:broadcast!).with(submission)
    Submission::TestRunsChannel.expects(:broadcast!).with(kind_of(Submission::TestRun))

    Submission::TestRun::Process.(job)

    assert submission.test_run
  end

  test "broadcast with iteration" do
    submission = create :submission
    iteration = create(:iteration, submission:)
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:)

    IterationChannel.expects(:broadcast!).with(iteration)
    SubmissionChannel.expects(:broadcast!).with(submission)
    Submission::TestRunsChannel.expects(:broadcast!).with(kind_of(Submission::TestRun))

    Submission::TestRun::Process.(job)
  end

  test "does not broadcast for solution run" do
    # see changes solution not submission for solution run for explanation of this setup
    exercise = create :practice_exercise, git_important_files_hash: 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
    solution = create(:practice_solution, :published, exercise:)
    submission = create :submission, solution:, git_sha: "b72b0958a135cddd775bf116c128e6e859bf11e4"
    create(:iteration, solution:, submission:)

    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(create(:submission), execution_status: 200, results:,
      git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a")

    IterationChannel.expects(:broadcast!).never
    SubmissionChannel.expects(:broadcast!).never
    Submission::TestRunsChannel.expects(:broadcast!).never

    Submission::TestRun::Process.(job)
  end

  test "changes solution not submission for solution run" do
    # Set the exercise and test run to be one sha, and the solution to be a different one
    # da39a3ee5e6b4b0d3255bfef95601890afd80709 is the hash of b72b0958a135cddd775bf116c128e6e859bf11e4
    exercise = create :practice_exercise, git_important_files_hash: 'da39a3ee5e6b4b0d3255bfef95601890afd80709'
    solution = create(:practice_solution, :published, exercise:)
    submission = create :submission, solution:, git_sha: "b72b0958a135cddd775bf116c128e6e859bf11e4"
    create(:iteration, solution:, submission:)
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:,
      git_sha: "ae1a56deb0941ac53da22084af8eb6107d4b5c3a")

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_not_queued?
    assert submission.solution.reload.published_iteration_head_tests_status_passed?
    assert submission.solution.reload.latest_iteration_head_tests_status_passed?
  end

  test "changes solution and submission if they're the same" do
    exercise = create :practice_exercise
    solution = create :practice_solution, :published, exercise:, git_sha: exercise.git_sha
    submission = create :submission, solution:, git_sha: exercise.git_sha
    create(:iteration, solution:, submission:)
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:, git_sha: exercise.git_sha)

    Submission::TestRun::Process.(job)

    assert submission.reload.tests_passed?
    assert submission.solution.reload.published_iteration_head_tests_status_passed?
  end

  test "auto updates version if applicable" do
    exercise = create :practice_exercise
    solution = create :practice_solution, :published, exercise:, git_sha: "foobar"
    submission = create(:submission, solution:)
    create(:iteration, solution:, submission:)
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:, git_sha: exercise.git_sha)

    # Sanity check
    refute_equal exercise.git_sha, solution.reload.git_sha

    Submission::TestRun::Process.(job)

    assert_equal exercise.git_sha, solution.reload.git_sha
  end

  test "calls update num submissions on representation" do
    solution = create :practice_solution, :published
    exercise = solution.exercise
    submission = create(:submission, solution:)
    representation = create :exercise_representation, ast_digest: 'foo', exercise:, source_submission: submission
    create(:submission_representation, ast_digest: representation.ast_digest, submission:)

    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    job = create_test_runner_job!(submission, execution_status: 200, results:)

    Exercise::Representation::UpdateNumSubmissions.expects(:defer).with(representation)
    Submission::TestRun::Process.(job)
  end
end
