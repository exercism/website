require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Components
  class EditorTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user runs tests and tests pass" do
      user = create :user
      create :user_auth_token, user: user
      solution = create :concept_solution, user: user

      use_capybara_host do
        visit test_components_editor_path(solution_id: solution.id)
        click_on "Run tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "pass",
          ops_status: 200,
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: pass"
        assert_text "Passed: test_a_name_given"
      end
    end

    test "user runs tests and tests fail" do
      user = create :user
      create :user_auth_token, user: user
      solution = create :concept_solution, user: user

      use_capybara_host do
        visit test_components_editor_path(solution_id: solution.id)
        click_on "Run tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "fail",
          ops_status: 200,
          tests: [{ name: :test_no_name_given, status: :fail }]
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: fail"
        assert_text "Failed: test_no_name_given"
      end
    end

    test "user runs tests and errors" do
      user = create :user
      create :user_auth_token, user: user
      solution = create :concept_solution, user: user

      use_capybara_host do
        visit test_components_editor_path(solution_id: solution.id)
        click_on "Run tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "error",
          message: "Undefined local variable",
          ops_status: 200,
          tests: []
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: error"
        assert_text "Undefined local variable"
      end
    end

    test "user runs tests and an ops error happens" do
      user = create :user
      create :user_auth_token, user: user
      solution = create :concept_solution, user: user

      use_capybara_host do
        visit test_components_editor_path(solution_id: solution.id)
        click_on "Run tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          status: "error",
          message: "Can't run the tests",
          ops_status: 400,
          tests: []
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "Status: ops_error"
        assert_text "Can't run the tests"
      end
    end

    test "user runs tests and cancels" do
      user = create :user
      create :user_auth_token, user: user
      solution = create :concept_solution, user: user

      use_capybara_host do
        visit test_components_editor_path(solution_id: solution.id)
        click_on "Run tests"
        wait_for_submission
        click_on "Cancel"

        assert_text "Status: cancelled"
      end
    end

    private
    def wait_for_submission
      assert_text "Status: queued"
    end
  end
end
