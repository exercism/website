require 'test_helper'

class Submission::TestRunTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:submission_test_run, ops_status: 199).ops_success?
    assert create(:submission_test_run, ops_status: 200).ops_success?
    refute create(:submission_test_run, ops_status: 201).ops_success?
  end

  test "ops_errored?" do
    assert create(:submission_test_run, ops_status: 199).ops_errored?
    refute create(:submission_test_run, ops_status: 200).ops_errored?
    assert create(:submission_test_run, ops_status: 201).ops_errored?
  end

  test "override ops error if no status" do
    test_run = create(:submission_test_run, raw_results: {})
    assert_equal 400, test_run.ops_status
    assert test_run.ops_errored?
  end

  test "don't overide ops error for empty 512" do
    test_run = create(:submission_test_run, ops_status: 512, raw_results: {})
    assert_equal 512, test_run.ops_status
    assert test_run.ops_errored?
  end

  test "explodes raw_results" do
    version = 5
    status = "foobar"
    message = "some barfoo message"
    tests = [{ 'status' => 'pass' }]

    raw_results = {
      version: version,
      status: status,
      message: message,
      tests: tests
    }
    tr = create :submission_test_run, raw_results: raw_results
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal version, tr.version
    assert_equal 1, tr.test_results.size
  end

  test "status" do
    tr = create :submission_test_run, status: 'pass'
    assert_equal :pass, tr.status
    assert tr.passed?
    refute tr.errored?
    refute tr.failed?

    tr = create :submission_test_run, status: 'error'
    assert_equal :error, tr.status
    refute tr.passed?
    assert tr.errored?
    refute tr.failed?

    tr = create :submission_test_run, status: 'fail'
    assert_equal :fail, tr.status
    refute tr.passed?
    refute tr.errored?
    assert tr.failed?
  end

  test "test_results" do
    name = "some name"
    status = "some status"
    test_code = "some cmd"
    message = "some message"
    expected = "Some expected"
    output = "\e[31mHello\e[0m\e[34mWorld\e[0"

    tests = [{
      'name' => name,
      'status' => status,
      'test_code' => test_code,
      'message' => message,
      'expected' => expected,
      'output' => output
    }]

    tr = create :submission_test_run, raw_results: { tests: tests }
    assert_equal 1, tr.test_results.size
    result = tr.test_results.first

    test_as_hash = {
      name: name,
      status: status.to_sym,
      test_code: test_code,
      message: message,
      message_html: message,
      expected: expected,
      output: output,
      output_html: "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>"
    }

    assert_equal test_as_hash, result.to_h
    assert_equal test_as_hash.to_json, result.to_json
    assert_equal test_as_hash, result.as_json(1, 2, 3) # Test with arbitary args
  end

  test "tooling_job" do
    submission = create :submission
    job = create_test_runner_job!(submission)
    Submission::TestRun::Process.(job)
    test_run = submission.test_run

    Exercism::ToolingJob.expects(:new).with(test_run.tooling_job_id, {}).returns(job)
    job.expects(:stdout)
    job.expects(:stderr)
    job.expects(:metadata)
    test_run.stdout
    test_run.stderr
    test_run.metadata
  end

  test "sets git sha and hash from submission" do
    submission = create :submission
    job = create_test_runner_job!(submission)
    Submission::TestRun::Process.(job)
    test_run = submission.test_run

    assert_equal submission.git_sha, test_run.git_sha
    assert_equal submission.git_important_files_hash, test_run.git_important_files_hash
  end

  test "correctly uses custom git_sha and important_files_hash" do
    old_sha = "37604404f19512548733f0eaeb319b93f63ac58b"
    old_hash = "b72b0958a135cddd775bf116c128e6e859bf11e4"

    ruby = create :track, slug: :ruby
    bob = create :practice_exercise, slug: :bob, track: ruby
    solution = create :practice_solution, exercise: bob
    submission = create :submission, solution: solution
    test_run = create :submission_test_run, git_sha: old_sha, submission: submission

    # Assert that the hash has been created from the old sha
    # which is different to the latest sha.
    assert_equal old_sha, test_run.git_sha
    assert_equal old_hash, test_run.git_important_files_hash
    refute_equal old_hash, bob.git_important_files_hash
  end

  # TODO: - Add a test for if the raw_results is empty
end
