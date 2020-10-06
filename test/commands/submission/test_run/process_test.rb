require 'test_helper'

class Submission::TestRun::ProcessTest < ActiveSupport::TestCase
  test "creates test_run record" do
    submission = create :submission
    ops_status = 201
    ops_message = "some ops message"
    status = "foobar"
    message = "some barfoo message"
    tests = [{ 'foo' => 'bar' }]
    results = { 'status' => status, 'message' => message, 'tests' => tests }

    Submission::TestRun::Process.(submission.uuid, ops_status, ops_message, results)

    assert_equal 1, submission.reload.test_runs.size
    tr = submission.reload.test_runs.first

    assert_equal ops_status, tr.ops_status
    assert_equal ops_message, tr.ops_message
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal tests, tr.tests
    assert_equal results, tr.send(:raw_results)
  end

  test "handle ops error" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    Submission::TestRun::Process.(submission.uuid, 500, "", results)

    assert submission.reload.tests_exceptioned?
  end

  test "handle tests pass" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    Submission::TestRun::Process.(submission.uuid, 200, "", results)

    assert submission.reload.tests_passed?
  end

  test "handle tests fail" do
    submission = create :submission
    results = { 'status' => 'fail', 'message' => "", 'tests' => [] }

    # Cancel reprsentation and analysis
    Submission::Representation::Cancel.expects(:call).with(submission.uuid)
    Submission::Analysis::Cancel.expects(:call).with(submission.uuid)

    Submission::TestRun::Process.(submission.uuid, 200, "", results)

    assert submission.reload.tests_failed?
  end

  test "handle tests error" do
    submission = create :submission
    results = { 'status' => 'error', 'message' => "", 'tests' => [] }

    # Cancel reprsentation and analysis
    Submission::Representation::Cancel.expects(:call).with(submission.uuid)
    Submission::Analysis::Cancel.expects(:call).with(submission.uuid)

    Submission::TestRun::Process.(submission.uuid, 200, "", results)

    assert submission.reload.tests_errored?
  end

  test "handle bad status" do
    submission = create :submission
    results = { 'status' => 'oops', 'message' => "", 'tests' => [] }
    Submission::TestRun::Process.(submission.uuid, 200, "", results)

    assert submission.reload.tests_exceptioned?
  end

  test "broadcast" do
    submission = create :submission
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }

    SubmissionChannel.expects(:broadcast!).with(submission)
    SubmissionsChannel.expects(:broadcast!).with(submission.solution)
    TestRunChannel.expects(:broadcast!).with(kind_of(Submission::TestRun))

    Submission::TestRun::Process.(submission.uuid, 200, "", results)

    assert_equal submission.test_runs.size, 1
  end
end
