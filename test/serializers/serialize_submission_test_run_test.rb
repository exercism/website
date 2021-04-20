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
      raw_results: { tests: [test] }

    actual = SerializeSubmissionTestRun.(test_run)

    expected = {
      id: test_run.id,
      submission_uuid: test_run.submission.uuid,
      version: 0,
      status: :pass,
      message: nil,
      message_html: nil,
      output: nil,
      output_html: nil,
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
    assert_equal message, output[:message_html]
  end

  test "message: returns nil if there is no message" do
    test_run = create :submission_test_run,
      ops_status: 200,
      raw_results: { message: nil }

    output = SerializeSubmissionTestRun.(test_run)

    assert_nil output[:message]
    assert_nil output[:message_html]
  end

  test "ops_error returns status and message" do
    test_run = create :submission_test_run,
      ops_status: 403,
      raw_results: { message: nil } # Override the factory

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal "ops_error", output[:status]
    assert_equal "An unknown error occurred", output[:message]
    assert_equal "An unknown error occurred", output[:message_html]
  end

  test "returns nil if nil is passed in" do
    assert_nil SerializeSubmissionTestRun.(nil)
  end

  test "ansi_in_message_html" do
    message = "\e[31mHello\e[0m\e[K\e[34mWorld\e[0"
    test_run = create :submission_test_run,
      ops_status: 403,
      raw_results: {
        version: 2,
        message: message
      }

    serialized = SerializeSubmissionTestRun.(test_run)

    assert_equal message, serialized[:message]
    assert_equal "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>", serialized[:message_html]
  end

  test "legacy v1 spec" do
    version = 5
    output = "\e[31mHello\e[0m\e[K\e[34mWorld\e[0"

    test_run = create :submission_test_run,
      ops_status: 403,
      raw_results: {
        version: version,
        output: output
      }

    serialized = SerializeSubmissionTestRun.(test_run)

    assert_equal version, serialized[:version]
    assert_equal output, serialized[:output]
    assert_equal "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>", serialized[:output_html]
  end
end
