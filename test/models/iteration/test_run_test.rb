require 'test_helper'

class Iteration::TestRunTest < ActiveSupport::TestCase
  test "explodes raw_results" do
    status = "foobar"
    message = "some barfoo message"
    tests = [{'foo' => 'bar'}]

    raw_results = {
      status: status,
      message: message,
      tests: tests
    }
    tr = create :iteration_test_run, raw_results: raw_results
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal tests, tr.tests
  end

  test "status" do
    tr = create :iteration_test_run, status: 'pass'
    assert_equal :pass, tr.status
    assert tr.passed?
    refute tr.errored?
    refute tr.failed?

    tr = create :iteration_test_run, status: 'error'
    assert_equal :error, tr.status
    refute tr.passed?
    assert tr.errored?
    refute tr.failed?

    tr = create :iteration_test_run, status: 'fail'
    assert_equal :fail, tr.status
    refute tr.passed?
    refute tr.errored?
    assert tr.failed?
  end
end
