require 'test_helper'

class Iteration::TestRun::ProcessTest < ActiveSupport::TestCase
  test "creates test_run record" do
    iteration = create :iteration
    ops_status = 201
    ops_message = "some ops message"
    status = "foobar"
    message = "some barfoo message"
    tests = [{ 'foo' => 'bar' }]
    results = { 'status' => status, 'message' => message, 'tests' => tests }

    Iteration::TestRun::Process.(iteration.uuid, ops_status, ops_message, results)

    assert_equal 1, iteration.reload.test_runs.size
    tr = iteration.reload.test_runs.first

    assert_equal ops_status, tr.ops_status
    assert_equal ops_message, tr.ops_message
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal tests, tr.tests
    assert_equal results, tr.send(:raw_results)
  end

  test "handle ops error" do
    iteration = create :iteration
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    Iteration::TestRun::Process.(iteration.uuid, 500, "", results)

    assert iteration.reload.tests_exceptioned?
  end

  test "handle tests pass" do
    iteration = create :iteration
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }
    Iteration::TestRun::Process.(iteration.uuid, 200, "", results)

    assert iteration.reload.tests_passed?
  end

  test "handle tests fail" do
    iteration = create :iteration
    results = { 'status' => 'fail', 'message' => "", 'tests' => [] }

    # Cancel representation and analysis
    ToolingJob::Cancel.expects(:call).with(iteration.uuid)

    Iteration::TestRun::Process.(iteration.uuid, 200, "", results)

    assert iteration.reload.tests_failed?
  end

  test "handle tests error" do
    iteration = create :iteration
    results = { 'status' => 'error', 'message' => "", 'tests' => [] }

    # Cancel representation and analysis
    ToolingJob::Cancel.expects(:call).with(iteration.uuid)

    Iteration::TestRun::Process.(iteration.uuid, 200, "", results)

    assert iteration.reload.tests_errored?
  end

  test "handle bad status" do
    iteration = create :iteration
    results = { 'status' => 'oops', 'message' => "", 'tests' => [] }
    Iteration::TestRun::Process.(iteration.uuid, 200, "", results)

    assert iteration.reload.tests_exceptioned?
  end

  test "broadcast" do
    iteration = create :iteration
    results = { 'status' => 'pass', 'message' => "", 'tests' => [] }

    IterationChannel.expects(:broadcast!).with(iteration)
    IterationsChannel.expects(:broadcast!).with(iteration.solution)
    TestRunChannel.expects(:broadcast!).with(kind_of(Iteration::TestRun))

    Iteration::TestRun::Process.(iteration.uuid, 200, "", results)

    assert_equal iteration.test_runs.size, 1
  end
end
