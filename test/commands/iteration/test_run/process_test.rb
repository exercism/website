require 'test_helper'

class Iteration::TestRun::ProcessTest < ActiveSupport::TestCase

  test "creates test_run record" do
    iteration = create :iteration
    ops_status = 201
    ops_message = "some ops message"
    status = "foobar"
    message = "some barfoo message"
    tests = [{'foo' => 'bar'}]
    results = {'status' => status, 'message' => message, 'tests' => tests}

    Iteration::TestRun::Process.(iteration.uuid, ops_status, ops_message, results)

    assert_equal 1, iteration.reload.test_runs.size
    tr = iteration.reload.test_runs.first

    assert_equal ops_status, tr.ops_status
    assert_equal ops_message, tr.ops_message
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal tests, tr.tests
    assert_equal results, tr.raw_results
  end
end
