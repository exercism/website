require 'test_helper'

class SerializeSubmissionTestRunTest < ActiveSupport::TestCase
  test "test successful run" do
    test = {
      'name' => 'test_a_name_given',
      'status' => 'pass',
      'output' => 'foobar'
    }
    test_run = create :submission_test_run,
      ops_status: 200,
      status: "pass",
      tests: [test]

    actual = SerializeSubmissionTestRun.(test_run)

    expected = {
      id: test_run.id,
      submission_uuid: test_run.submission.uuid,
      status: :pass,
      message: test_run.message,
      tests: [
        {
          name: 'test_a_name_given',
          status: 'pass',
          test_code: nil,
          message: nil,
          expected: nil,
          output: 'foobar',
          output_html: "foobar"
        }
      ]
    }
    assert_equal expected.to_json, actual.to_json
  end

  test "status: proxies fail" do
    test_run = create :submission_test_run,
      ops_status: 200,
      status: 'fail'

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal :fail, output[:status]
  end

  test "status: proxies error" do
    test_run = create :submission_test_run,
      ops_status: 200,
      status: 'error'

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal :error, output[:status]
  end

  test "status: returns error if unexpected" do
    test_run = create :submission_test_run,
      ops_status: 200,
      status: 'foobar'

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal :error, output[:status]
  end

  test "message: returns message if there is one" do
    message = "foobar"
    test_run = create :submission_test_run, message: message

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal message, output[:message]
  end

  test "message: returns nil if there is no message" do
    test_run = create :submission_test_run,
      ops_status: 200,
      raw_results: { message: nil }

    output = SerializeSubmissionTestRun.(test_run)

    assert_nil output[:message]
  end

  test "ops_error returns status and message" do
    test_run = create :submission_test_run,
      ops_status: 403,
      raw_results: { message: nil } # Override the factory

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal "ops_error", output[:status]
    assert_equal "Some error occurred", output[:message]
  end

  test "returns nil if nil is passed in" do
    assert_nil SerializeSubmissionTestRun.(nil)
  end
end
