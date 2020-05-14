require 'test_helper'

class Iteration::TestRunTest < ActiveSupport::TestCase
  test "ops_success?" do
    refute create(:iteration_test_run, ops_status: 199).ops_success?
    assert create(:iteration_test_run, ops_status: 200).ops_success?
    refute create(:iteration_test_run, ops_status: 201).ops_success?
  end

  test "explodes raw_results" do
    status = "foobar"
    message = "some barfoo message"
    tests = [{'status' => 'pass'}]

    raw_results = {
      status: status,
      message: message,
      tests: tests
    }
    tr = create :iteration_test_run, raw_results: raw_results
    assert_equal status.to_sym, tr.status
    assert_equal message, tr.message
    assert_equal tests, tr.tests
    assert_equal 1, tr.test_results.size
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

  test "test_results" do
    name = "some name"
    status = "some status"
    cmd = "some cmd"
    message = "some message"
    expected = "Some expected"
    output = "\e[31mHello\e[0m\e[34mWorld\e[0"
    
    tests = [{
      'name' => name,
      'status' => status,
      'cmd' => cmd,
      'message' => message,
      'expected' => expected,
      'output' => output
    }]

    tr = create :iteration_test_run, tests: tests
    assert_equal 1, tr.test_results.size
    result =  tr.test_results.first

    assert_equal name, result.name
    assert_equal status.to_sym, result.status
    assert_equal cmd, result.cmd
    assert_equal message, result.message
    assert_equal expected, result.expected
    assert_equal "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>", result.output_html
  end

  # TODO - Add a test for if the raw_results is empty
end
