require 'test_helper'
class TestRunnerFlowTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "runs the tests for a basic submission" do
    solution = create(:concept_solution)

    submission = Submission::Create.(solution, files, :cli)
    perform_enqueued_jobs

    assert_equal 'queued', submission.tests_status
    assert_equal :not_queued, solution.reload.latest_iteration_head_tests_status
    assert_equal :not_queued, solution.reload.published_iteration_head_tests_status

    ##
    ## Simulate the job coming back and being processed
    ##
    perform_enqueued_jobs do
      job = create_test_run_job(submission)
      Submission::TestRun::Process.(job)
    end

    assert_equal 'passed', submission.reload.tests_status
    assert_equal :not_queued, solution.reload.latest_iteration_head_tests_status
    assert_equal :not_queued, solution.reload.published_iteration_head_tests_status
  end

  test "runs the tests for an iteration submission" do
    # Stub things we don't care about here
    GenerateIterationSnippetJob.any_instance.expects(:perform)
    CalculateLinesOfCodeJob.any_instance.expects(:perform)

    solution = create(:concept_solution)
    user_track = create :user_track, user: solution.user, track: solution.track

    submission = Submission::Create.(solution, files, :cli)
    Iteration::Create.(solution, submission)
    perform_enqueued_jobs

    assert_equal 'queued', submission.tests_status
    assert_equal :queued, solution.reload.latest_iteration_head_tests_status
    assert_equal :not_queued, solution.reload.published_iteration_head_tests_status

    ##
    ## Simulate the job coming back and being processed
    ##
    perform_enqueued_jobs do
      job = create_test_run_job(submission)
      Submission::TestRun::Process.(job)
    end

    assert_equal 'passed', submission.reload.tests_status
    assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    assert_equal :not_queued, solution.reload.published_iteration_head_tests_status

    ##
    ## Now publish the solution
    ##
    perform_enqueued_jobs do
      Solution::Publish.(solution, user_track, nil)
    end

    assert_equal 'passed', submission.reload.tests_status
    assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    assert_equal :passed, solution.reload.published_iteration_head_tests_status
  end

  test "handles a new git sha being pushed" do
    # Stub things we don't care about here
    GenerateIterationSnippetJob.any_instance.expects(:perform)
    CalculateLinesOfCodeJob.any_instance.expects(:perform)

    exercise = create :practice_exercise, git_sha: '0b04b8976650d993ecf4603cf7413f3c6b898eff'
    solution = create(:practice_solution, exercise:)
    user_track = create :user_track, user: solution.user, track: solution.track

    # Let's get to a starting state
    submission = Submission::Create.(solution, files, :cli)
    Iteration::Create.(solution, submission)
    job = create_test_run_job(submission)
    Submission::TestRun::Process.(job)
    Solution::Publish.(solution, user_track, nil)
    perform_enqueued_jobs
    submission.reload
    solution.reload

    # Store real values
    git_sha = exercise.git_sha
    git_important_files_hash = exercise.git_important_files_hash

    # These need to be updated in this reverse order for things to work :)
    submission.test_run.update_columns(git_sha: "foobar", git_important_files_hash: "barfoo")
    submission.update_columns(git_sha: "foobar", git_important_files_hash: "barfoo")
    solution.update_columns(git_sha: "foobar", git_important_files_hash: "barfoo")
    exercise.update_columns(git_sha: "foobar", git_important_files_hash: "barfoo")

    # And perform some sanity checks
    assert_equal 'passed', submission.reload.tests_status
    assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    assert_equal :passed, solution.reload.published_iteration_head_tests_status

    ##
    ## Simulate exercise update
    ##
    Exercise::MarkSolutionsAsOutOfDateInIndex.expects(:call)
    ToolingJob::Create.expects(:call).with(
      submission,
      :test_runner,
      git_sha:,
      run_in_background: true
    )

    exercise.update(git_sha:, git_important_files_hash:)
    perform_enqueued_jobs

    # These shouldn't be changed
    assert_equal 'passed', submission.reload.tests_status
    assert_equal :passed, solution.reload.latest_iteration_head_tests_status
    assert_equal :passed, solution.reload.published_iteration_head_tests_status

    ##
    ## Simulate the job coming back and being processed
    ##
    perform_enqueued_jobs do
      job = create_test_run_job(submission, status: :fail, git_sha:)
      Submission::TestRun::Process.(job)
    end

    # The original solution is still passing as it's test run is still
    # the original one but the iteration is now failing latest head status
    assert_equal 'passed', submission.reload.tests_status
    assert_equal :failed, solution.reload.latest_iteration_head_tests_status
    assert_equal :failed, solution.reload.published_iteration_head_tests_status

    ##
    ## Update the solution to the latest version
    ##
    Solution::UpdateToLatestExerciseVersion.(solution)
    perform_enqueued_jobs

    # The status should sync up properly.
    assert_equal 'failed', submission.reload.tests_status
    assert_equal :failed, solution.reload.latest_iteration_head_tests_status
    assert_equal :failed, solution.reload.published_iteration_head_tests_status
  end

  def files
    [{ filename: "subdir/foobar.rb", content: "'I think' = 'I am'" }]
  end

  def create_test_run_job(submission, status: :pass, git_sha: nil)
    ops_status = 200
    message = "some barfoo message"
    version = 5
    tests = [{ 'foo' => 'bar' }]
    results = { 'version' => version, 'status' => status, 'message' => message, 'tests' => tests }
    create_test_runner_job!(submission, execution_status: ops_status, results:, git_sha:)
  end
end
