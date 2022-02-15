require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class UserViewsTestsStatusTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user views v3 test run's test status" do
        track = create :track
        exercise = create :concept_exercise, track: track
        author = create :user, handle: "author"
        solution = create :concept_solution, :completed, :published, user: author, exercise: exercise
        submission = create :submission, solution: solution, tests_status: :failed
        create :iteration, submission: submission
        create :submission_test_run,
          submission: submission,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail, task_id: 1 }]
          }

        use_capybara_host do
          sign_in!
          visit track_exercise_solution_url(track, exercise, "author")
          click_on "Failed"

          assert_text "2 / 3 TASKS COMPLETED"
        end
      end

      test "user views v2 test run's test status" do
        track = create :track
        exercise = create :concept_exercise, track: track
        author = create :user, handle: "author"
        solution = create :concept_solution, :completed, :published, user: author, exercise: exercise
        submission = create :submission, solution: solution, tests_status: :failed
        create :iteration, submission: submission
        create :submission_test_run,
          submission: submission,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail }]
          }

        use_capybara_host do
          sign_in!
          visit track_exercise_solution_url(track, exercise, "author")
          click_on "Failed"

          assert_text "1 TEST FAILURE"
        end
      end

      test "user views v1 test run's test status" do
        track = create :track
        exercise = create :concept_exercise, track: track
        author = create :user, handle: "author"
        solution = create :concept_solution, :completed, :published, user: author, exercise: exercise
        submission = create :submission, solution: solution, tests_status: :failed
        create :iteration, submission: submission
        create :submission_test_run,
          submission: submission,
          ops_status: 200,
          raw_results: {
            version: 1,
            status: "fail",
            message: "Test 2 failed"
          }

        use_capybara_host do
          sign_in!
          visit track_exercise_solution_url(track, exercise, "author")
          click_on "Failed"

          assert_text "TESTS FAILED"
        end
      end
    end
  end
end
