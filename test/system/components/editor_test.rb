require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/ace_helpers"

module Components
  class EditorTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include CodeMirrorHelpers

    test "user runs tests and tests pass with - v3 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "pass",
            tests: [{ name: :test_a_name_given, status: :pass, output: "Hello", task_id: 1 }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "1 test passed"
      end
    end

    test "user runs tests and tests pass - v2 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "pass",
            tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "1 test passed"
      end
    end

    test "user runs tests and tests pass with - v1 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 1,
            status: "pass"
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "ALL TESTS PASSED"
      end
    end

    test "user gets tests results even if websockets broadcast fails" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "pass",
            tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
          }

        assert_text "1 test passed"
      end
    end

    test "user runs tests and tests fail - v3 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail, task_id: 1 }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "1 test failed"
      end
    end

    test "user runs tests and tests fail - v2 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail }]
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "1 test failed"
      end
    end

    test "user runs tests and tests fail - v1 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        message = "Oh dear Foobar - here's some stuff"
        test_run = create :submission_test_run,
          submission: Submission.last,
          ops_status: 200,
          raw_results: {
            version: 1,
            status: "fail",
            message: message
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "TESTS FAILED"
        assert_text message
      end
    end

    test "user runs tests and errors" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        2.times { wait_for_websockets }
        test_run = create :submission_test_run,
          submission: Submission.last,
          message: "Undefined local variable",
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "error",
            tests: []
          }
        Submission::TestRunsChannel.broadcast!(test_run)

        assert_text "AN ERROR OCCURRED"
        assert_text "Undefined local variable"
      end
    end

    test "user runs tests and an ops error happens" do
      expecting_errors do
        user = create :user
        strings = create :concept_exercise
        solution = create :concept_solution, user: user, exercise: strings

        use_capybara_host do
          sign_in!(user)
          visit test_components_editor_path(solution_id: solution.id)
          fill_in_editor "test"
          click_on "Run Tests"
          wait_for_submission
          2.times { wait_for_websockets }
          test_run = create :submission_test_run,
            submission: Submission.last,
            message: "Can't run the tests",
            ops_status: 400,
            raw_results: {
              version: 2,
              status: "error",
              tests: []
            }
          Submission::TestRunsChannel.broadcast!(test_run)

          assert_text "AN ERROR OCCURRED"
          assert_text "An error occurred while running your tests"
        end
      end
    end

    test "user runs tests and cancels" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        fill_in_editor "test"
        click_on "Run Tests"
        wait_for_submission
        click_on "Cancel"

        assert_no_text "Running tests..."
      end
    end

    test "user sees previous test results - v3 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 3,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello", task_id: 1 }]
        }

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)

        assert_text "1 test passed"
      end
    end

    test "user sees previous test results - v2 test runner" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution
      create :submission_test_run,
        submission: submission,
        ops_status: 200,
        raw_results: {
          version: 2,
          status: "pass",
          tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
        }

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)

        assert_text "1 test passed"
      end
    end

    test "user reverts to last iteration" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "old content",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("old content")
      create :iteration, submission: submission
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "new content",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("new content")

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        find(".more-btn").click
        click_on("Revert to last iteration")

        assert_text "old content"
      end
    end

    test "user reverts to original exercise solution" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution
      create :submission_file,
        submission: submission,
        content: "new content",
        filename: "log_line_parser.rb",
        digest: Digest::SHA1.hexdigest("new content")

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        find(".more-btn").click
        click_on("Revert to exercise start")

        assert_text "Please implement the LogLineParser.message method"
      end
    end

    test "user reports a bug" do
      user = create :user
      strings = create :concept_exercise
      solution = create :concept_solution, user: user, exercise: strings

      use_capybara_host do
        sign_in!(user)
        visit test_components_editor_path(solution_id: solution.id)
        find(".more-btn").click
        click_on("Report a bug")
        fill_in "Report", with: "I found a bug"
        click_on "Submit"

        assert_text "Thanks for submitting a bug report"
      end
    end

    private
    def wait_for_submission
      assert_text "Running tests..."
    end
  end
end
