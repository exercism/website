require 'test_helper'

class SerializeSubmissionTestRunTest < ActiveSupport::TestCase
  test "test successful v3 run" do
    test = {
      'name' => 'test_a_name_given',
      'status' => 'pass',
      'output' => 'foobar'
    }
    test_run = create :submission_test_run,
      ops_status: 200,
      status: "pass",
      raw_results: { version: 3, tests: [test], status: "pass" }

    actual = SerializeSubmissionTestRun.(test_run)

    expected = {
      uuid: test_run.uuid,
      submission_uuid: test_run.submission.uuid,
      version: 3,
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
          message_html: nil,
          expected: nil,
          output: 'foobar',
          output_html: "foobar",
          task_id: nil
        }
      ],
      tasks: [
        { id: 1, title: "Get message from a log line" },
        { id: 2, title: "Get log level from a log line" },
        { id: 3, title: "Reformat a log line" }
      ],
      highlightjs_language: 'ruby',
      links: {
        self: Exercism::Routes.api_solution_submission_test_run_url(test_run.solution.uuid, test_run.submission.uuid)
      }
    }

    assert_equal expected.to_json, actual.to_json
  end

  test "test successful v2 run" do
    test = {
      'name' => 'test_a_name_given',
      'status' => 'pass',
      'output' => 'foobar'
    }
    test_run = create :submission_test_run,
      ops_status: 200,
      status: "pass",
      raw_results: { version: 2, tests: [test], status: "pass" }

    actual = SerializeSubmissionTestRun.(test_run)

    expected = {
      uuid: test_run.uuid,
      submission_uuid: test_run.submission.uuid,
      version: 2,
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
          message_html: nil,
          expected: nil,
          output: 'foobar',
          output_html: "foobar",
          task_id: nil
        }
      ],
      tasks: [],
      highlightjs_language: 'ruby',
      links: {
        self: Exercism::Routes.api_solution_submission_test_run_url(test_run.solution.uuid, test_run.submission.uuid)
      }
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

  test "status: returns timeout if timed out" do
    test_run = create :submission_test_run,
      ops_status: 408,
      status: 'foobar'

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal 'timeout', output[:status]
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
    test_run = create(:submission_test_run, message:)

    output = SerializeSubmissionTestRun.(test_run)

    assert_equal message, output[:message]
    assert_equal message, output[:message_html]
  end

  test "message: returns nil if there is no message" do
    test_run = create :submission_test_run,
      ops_status: 200,
      raw_results: { message: nil, status: "pass" }

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
        message:
      }

    serialized = SerializeSubmissionTestRun.(test_run)

    assert_equal message, serialized[:message]
    assert_equal "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>", serialized[:message_html]
  end

  test "legacy v1 spec" do
    version = 1
    output = "\e[31mHello\e[0m\e[K\e[34mWorld\e[0"

    test_run = create :submission_test_run,
      ops_status: 403,
      raw_results: {
        version:,
        output:
      }

    serialized = SerializeSubmissionTestRun.(test_run)

    assert_equal version, serialized[:version]
    assert_equal output, serialized[:output]
    assert_equal "<span style='color:#A00;'>Hello</span><span style='color:#00A;'>World</span>", serialized[:output_html]
    assert_empty serialized[:tests]
    assert_empty serialized[:tasks]
  end

  test "tasks: serialized for v3 run" do
    test = {
      'name' => 'test_a_name_given',
      'status' => 'pass',
      'output' => 'foobar'
    }
    test_run = create :submission_test_run,
      ops_status: 200,
      status: "pass",
      raw_results: { version: 3, tests: [test], status: "pass" }

    actual = SerializeSubmissionTestRun.(test_run)

    expected = [
      { id: 1, title: "Get message from a log line" },
      { id: 2, title: "Get log level from a log line" },
      { id: 3, title: "Reformat a log line" }
    ]
    assert_equal expected, actual[:tasks]
  end

  test "tasks: empty for v2 run" do
    test = {
      'name' => 'test_a_name_given',
      'status' => 'pass',
      'output' => 'foobar'
    }
    test_run = create :submission_test_run,
      ops_status: 200,
      status: "pass",
      raw_results: { version: 2, tests: [test], status: "pass" }

    actual = SerializeSubmissionTestRun.(test_run)

    assert_empty actual[:tasks]
  end

  test "tasks: empty for v1 run" do
    test_run = create :submission_test_run,
      ops_status: 200,
      status: "pass",
      raw_results: { version: 1, status: "pass" }

    actual = SerializeSubmissionTestRun.(test_run)

    assert_empty actual[:tasks]
  end
end
