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
    Iteration::GenerateSnippet.any_instance.stubs(:call)
    Solution::UpdateNumLoc.any_instance.stubs(:call)
    Iteration::CountLinesOfCode.any_instance.stubs(:call)

    solution = create(:concept_solution)
    user_track = create :user_track, user: solution.user, track: solution.track

    submission = Submission::Create.(solution, files, :cli)
    Iteration::Create.(solution, submission)
    perform_enqueued_jobs
    solution.reload
    submission.reload

    assert_equal 'queued', submission.tests_status
    assert_equal :queued, solution.latest_iteration_head_tests_status
    assert_equal :not_queued, solution.published_iteration_head_tests_status

    ##
    ## Simulate the job coming back and being processed
    ##
    perform_enqueued_jobs do
      job = create_test_run_job(submission)
      Submission::TestRun::Process.(job)
    end
    solution.reload
    submission.reload

    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :not_queued, solution.published_iteration_head_tests_status

    ##
    ## Now publish the solution
    ##
    perform_enqueued_jobs do
      Solution::Publish.(solution, user_track, nil)
    end
    solution.reload
    submission.reload

    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status
  end

  test "handles a new git sha being pushed: failing" do
    # Stub things we don't care about here
    Iteration::GenerateSnippet.any_instance.stubs(:call)
    Solution::UpdateNumLoc.any_instance.stubs(:call)
    Iteration::CountLinesOfCode.any_instance.stubs(:call)

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

    # Stub a representation so we don't get jobs for it later.
    create(:submission_representation, submission:)

    # Store real values
    git_sha = exercise.git_sha
    git_important_files_hash = exercise.git_important_files_hash

    old_git_sha = "foobar"
    old_git_important_files_hash = "barfoo"

    # These need to be updated in this reverse order for things to work :)
    submission.test_run.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)
    submission.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)
    solution.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)
    exercise.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)

    # And perform some sanity checks
    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status

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

    perform_enqueued_jobs do
      exercise.update(git_sha:, git_important_files_hash:)
    end
    solution.reload
    submission.reload

    # These shouldn't be changed
    assert_equal old_git_sha, submission.git_sha
    assert_equal old_git_important_files_hash, submission.git_important_files_hash
    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status

    ##
    ## Simulate the job coming back and being processed
    ##
    perform_enqueued_jobs do
      job = create_test_run_job(submission, status: :fail, git_sha:)
      Submission::TestRun::Process.(job)
    end
    solution.reload
    submission.reload

    # The original solution is still passing as it's test run is still
    # the original one but the iteration is now failing latest head status
    assert_equal old_git_sha, solution.git_sha
    assert_equal old_git_important_files_hash, solution.git_important_files_hash
    assert_equal old_git_sha, submission.git_sha
    assert_equal old_git_important_files_hash, submission.git_important_files_hash
    assert_equal 'passed', submission.tests_status
    assert_equal :failed, solution.latest_iteration_head_tests_status
    assert_equal :failed, solution.published_iteration_head_tests_status

    ##
    ## Update the solution to the latest version
    ##
    Solution::UpdateToLatestExerciseVersion.(solution)
    perform_enqueued_jobs
    solution.reload
    submission.reload

    # The status should sync up properly.
    assert_equal git_sha, solution.git_sha
    assert_equal git_important_files_hash, solution.git_important_files_hash
    assert_equal git_sha, submission.git_sha
    assert_equal git_important_files_hash, submission.git_important_files_hash
    assert_equal 'failed', submission.tests_status
    assert_equal :failed, solution.latest_iteration_head_tests_status
    assert_equal :failed, solution.published_iteration_head_tests_status
  end

  test "handles a new git sha being pushed: passing auto updates" do
    # Stub things we don't care about here
    Iteration::GenerateSnippet.any_instance.stubs(:call)
    Solution::UpdateNumLoc.any_instance.stubs(:call)
    Iteration::CountLinesOfCode.any_instance.stubs(:call)

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

    # Stub a representation so we don't get jobs for it later.
    create(:submission_representation, submission:)

    # Store real values
    git_sha = exercise.git_sha
    git_important_files_hash = exercise.git_important_files_hash

    old_git_sha = "foobar"
    old_git_important_files_hash = "barfoo"

    # These need to be updated in this reverse order for things to work :)
    submission.test_run.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)
    submission.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)
    solution.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)
    exercise.update_columns(git_sha: old_git_sha, git_important_files_hash: old_git_important_files_hash)

    # And perform some sanity checks
    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status

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
    # ToolingJob::Create.expects(:call).with(
    #   submission,
    #   :representer,
    #   git_sha:,
    #   run_in_background: true,
    #   context: {}
    # )

    perform_enqueued_jobs do
      exercise.update(git_sha:, git_important_files_hash:)
    end
    submission.reload
    solution.reload

    # These shouldn't be changed
    assert_equal old_git_sha, submission.git_sha
    assert_equal old_git_important_files_hash, submission.git_important_files_hash
    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status

    ##
    ## Simulate the job coming back and being processed
    ##
    perform_enqueued_jobs do
      job = create_test_run_job(submission, status: :pass, git_sha:)
      Submission::TestRun::Process.(job)
    end
    solution.reload
    submission.reload

    # The status should sync up properly.
    assert_equal git_sha, solution.git_sha
    assert_equal git_important_files_hash, solution.git_important_files_hash
    assert_equal git_sha, submission.git_sha
    assert_equal git_important_files_hash, submission.git_important_files_hash
    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status
  end

  test "honours [no important files changed] and auto-updates" do
    # Stub things we don't care about here
    Iteration::GenerateSnippet.any_instance.stubs(:call)
    Solution::UpdateNumLoc.any_instance.stubs(:call)
    Iteration::CountLinesOfCode.any_instance.stubs(:call)

    # This exercise contains the right set of things to
    # go with this commit for this test.
    exercise_slug = 'satellite'

    # Store real values
    old_git_sha = "0b04b8976650d993ecf4603cf7413f3c6b898eff"
    old_git_important_files_hash = "6a0ca80a08e8451991e09a2483ddceb0f698b21a"

    git_sha = "cfd8cf31bb9c90fd9160c82db69556a47f7c2a54"
    git_important_files_hash = "cb8f62b17f71f9c95d1753ec542c186a3cc6a08e"

    exercise = create :practice_exercise, slug: exercise_slug, git_sha: old_git_sha,
      git_important_files_hash: old_git_important_files_hash
    solution = create(:practice_solution, exercise:)
    user_track = create :user_track, user: solution.user, track: solution.track

    # Let's get to a starting state
    submission = Submission::Create.(solution, files, :cli)
    Iteration::Create.(solution, submission)
    job = create_test_run_job(submission)
    Submission::TestRun::Process.(job)
    Solution::Publish.(solution, user_track, nil)
    perform_enqueued_jobs
    exercise.reload
    submission.reload
    solution.reload

    # Perform some sanity checks
    assert_equal old_git_sha, exercise.git_sha
    assert_equal old_git_sha, solution.git_sha
    assert_equal old_git_sha, submission.git_sha
    assert_equal old_git_sha, submission.test_run.git_sha
    assert_equal old_git_important_files_hash, exercise.git_important_files_hash
    assert_equal old_git_important_files_hash, solution.git_important_files_hash
    assert_equal old_git_important_files_hash, submission.git_important_files_hash
    assert_equal old_git_important_files_hash, submission.test_run.git_important_files_hash
    assert_equal 'passed', submission.tests_status
    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status

    ##
    ## Simulate exercise update with the flag used
    ##

    # Both of these should explicitly not get called.
    Exercise::MarkSolutionsAsOutOfDateInIndex.expects(:call).never
    ToolingJob::Create.expects(:call).never

    exercise.update!(git_sha:, git_important_files_hash:)
    perform_enqueued_jobs
    solution.reload
    submission.reload

    # Everything should be updated
    assert_equal git_sha, exercise.git_sha
    assert_equal git_sha, solution.git_sha
    assert_equal git_sha, submission.git_sha
    assert_equal git_sha, submission.test_run.git_sha
    assert_equal git_important_files_hash, exercise.git_important_files_hash
    assert_equal git_important_files_hash, solution.git_important_files_hash
    assert_equal git_important_files_hash, submission.git_important_files_hash
    assert_equal git_important_files_hash, submission.test_run.git_important_files_hash

    # The tests should be as they were without a test run being created
    assert_equal 'passed', submission.tests_status
    assert_equal :passed, solution.latest_iteration_head_tests_status
    assert_equal :passed, solution.published_iteration_head_tests_status
  end

  private
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
