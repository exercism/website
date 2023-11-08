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
      version:,
      status:,
      message:,
      tests:
    }
    tr = create(:submission_test_run, raw_results:)
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

  test "test_results - version 1" do
    tr = create :submission_test_run, raw_results: {
      version: 1,
      status: 'fail',
      message: 'Test 2 failed'
    }
    assert_equal 1, tr.version
    assert_equal :fail, tr.status
    assert_equal 'Test 2 failed', tr.message
    assert_empty tr.test_results
  end

  test "test_results - version 2" do
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

    tr = create :submission_test_run, raw_results: {
      version: 2,
      status: 'pass',
      tests:
    }
    assert_equal 2, tr.version
    assert_equal :pass, tr.status
    assert_equal 1, tr.test_results.size
    result = tr.test_results.first

    test_as_hash = {
      name:,
      status: status.to_sym,
      test_code:,
      message:,
      message_html: message,
      expected:,
      output:,
      output_html: "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>",
      task_id: nil
    }

    assert_equal test_as_hash, result.to_h
    assert_equal test_as_hash.to_json, result.to_json
    assert_equal test_as_hash, result.as_json(1, 2, 3) # Test with arbitary args
  end

  test "test_results - name is stringified" do
    name = { foo: 'bar' }
    tests = [{ 'name' => name }]

    tr = create :submission_test_run, raw_results: {
      version: 2,
      status: 'pass',
      tests:
    }
    expected = JSON.parse(JSON.generate(name)).to_s
    assert_equal expected, tr.test_results.first.to_h[:name]
  end

  test "test_results - version 3" do
    name = "some name"
    status = "some status"
    test_code = "some cmd"
    message = "some message"
    expected = "Some expected"
    output = "\e[31mHello\e[0m\e[34mWorld\e[0"
    task_id = 7

    tests = [{
      'name' => name,
      'status' => status,
      'test_code' => test_code,
      'message' => message,
      'expected' => expected,
      'output' => output,
      'task_id' => task_id
    }]

    tr = create :submission_test_run, raw_results: {
      version: 3,
      status: 'pass',
      tests:
    }
    assert_equal 3, tr.version
    assert_equal :pass, tr.status
    assert_equal 1, tr.test_results.size
    result = tr.test_results.first

    test_as_hash = {
      name:,
      status: status.to_sym,
      test_code:,
      message:,
      message_html: message,
      expected:,
      output:,
      output_html: "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>",
      task_id:
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
    old_sha = "e333c0137fd8faaf519bc606fb510f9d5411482c"
    old_hash = "a52dbbf7a75e7f883b717ad215bc0553ccd18694"

    ruby = create :track, slug: :ruby
    bob = create :practice_exercise, slug: :bob, track: ruby
    solution = create :practice_solution, exercise: bob
    submission = create(:submission, solution:)
    test_run = create(:submission_test_run, git_sha: old_sha, submission:)

    # Assert that the hash has been created from the old sha
    # which is different to the latest sha.
    assert_equal old_sha, test_run.git_sha
    assert_equal old_hash, test_run.git_important_files_hash
    refute_equal old_hash, bob.git_important_files_hash
  end

  # TODO: - Add a test for if the raw_results is empty

  test "track: inferred from submission" do
    submission = create :submission
    test_run = create(:submission_test_run, submission:)

    assert_equal submission.track, test_run.track
  end

  test "truncate message" do
    message = 'a' * 66_000
    test_run = create(:submission_test_run, raw_results: { message: })

    assert test_run.message.bytesize < 65_536
  end
end
