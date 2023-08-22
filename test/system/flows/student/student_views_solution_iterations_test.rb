require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Student
    class StudentViewsSolutionIterationsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "opens and closes iterations as expected" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)

        submission_1 = create(:submission, tests_status: :queued, solution:)
        create :iteration, idx: 1, solution:, submission: submission_1
        create :submission_file, submission: submission_1

        submission_2 = create(:submission, tests_status: :queued, solution:)
        create :iteration, idx: 2, solution:, submission: submission_2
        create :submission_file, submission: submission_2

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_equal "true", find("details", text: "Iteration 2")['open']
          assert_equal "false", find("details", text: "Iteration 1")['open']

          find("summary", text: "Iteration 2").click
          assert_equal "false", find("details", text: "Iteration 2")['open']
          assert_equal "false", find("details", text: "Iteration 1")['open']

          find("summary", text: "Iteration 2").click
          assert_equal "true", find("details", text: "Iteration 2")['open']
          assert_equal "false", find("details", text: "Iteration 1")['open']

          find("summary", text: "Iteration 1").click
          assert_equal "true", find("details", text: "Iteration 2")['open']
          assert_equal "true", find("details", text: "Iteration 1")['open']
        end
      end

      test "opens newest iteration when there are no iterations open" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, tests_status: :queued, solution:, submitted_via: :cli
        create(:iteration, idx: 2, solution:, submission:)
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          find("summary").click

          create(:iteration, idx: 3, solution:)
          SolutionChannel.broadcast!(solution)
          assert_equal find("details", text: "Iteration 3")['open'], "true"
        end
      end

      test "does not open newest iteration when there are iterations open" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        create(:hello_world_solution, :completed, track:, user:)

        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, tests_status: :queued, solution:, submitted_via: :cli
        create(:iteration, idx: 2, solution:, submission:)
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          sleep(0.2) # Give the websockets time to attach

          create(:iteration, idx: 3, solution:)
          SolutionChannel.broadcast!(solution)

          assert_equal "false", find("details", text: "Iteration 3")['open']
        end
      end

      test "user sees zero state" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        create(:concept_solution, exercise:, user:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "You haven't submitted any iterations yet."
        end
      end

      test "user starts exercise in zero state" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        create(:concept_solution, exercise:, user:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Start in Editor"

          assert_text "Introduction"
        end
      end

      test "user views iteration files" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, tests_status: :queued, solution:, submitted_via: :cli
        create(:iteration, idx: 2, solution:, submission:)
        create :submission_file, submission:, content: "class Bob\n"

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "class Bob"
        end
      end

      test "user views processing iteration" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create(:submission, tests_status: :queued, solution:)
        create(:iteration, solution:, submission:)
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "We're analysing your code for suggestions"

          click_on "Tests"
          assert_text "We're testing your code to check it works"
        end
      end

      test "user views iteration with no automated feedback" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "No auto suggestions? Try human mentoring."
        end
      end

      test "user views iteration with failed tests" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:, tests_status: :failed
        create(:iteration, solution:, submission:)
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "In order for our systems to analyze your code, the tests must be passing."
        end
      end

      test "user views representer feedback" do
        user = create :user
        author = create :user, name: "Feedback author"
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create :exercise_representation,
          exercise:,
          source_submission: submission,
          feedback_author: author,
          feedback_markdown: "Good job",
          feedback_type: :essential,
          ast_digest: "AST"
        create :submission_representation,
          submission:,
          ast_digest: "AST"
        create(:iteration, solution:, submission:)
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_path(track, exercise)

          assert_text "Feedback author gave this feedback on a solution very similar to yours"
          assert_text "Good job"
        end
      end

      test "user views analyzer feedback" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)
        create(:submission_file, submission:)
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "essential", comment: "ruby.two-fer.splat_args" }
          ]
        }

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "Our Ruby Analyzer generated this feedback when analyzing your solution."
          assert_text "Define an explicit"
        end
      end

      test "user views v3 test run" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)
        create :submission_test_run,
          submission:,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "fail",
            tests: [
              { name: :test_no_name_given, status: :fail, task_id: 1 },
              { name: :test_something_else, status: :fail, task_id: 1 }
            ]
          }

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Tests"

          assert_text "2 / 3 Tasks Completed"
        end
      end

      test "user views v3 test run with missing task" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)
        create :submission_test_run,
          submission:,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "fail",
            tests: [
              { name: :test_no_name_given, status: :fail, task_id: 1 },
              { name: :test_something_else, status: :fail }
            ]
          }

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Tests"

          assert_text "2 TEST FAILURES"
          assert_text "2 tests failed"
        end
      end

      test "user views v2 test run" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)
        create :submission_test_run,
          submission:,
          ops_status: 200,
          raw_results: {
            version: 2,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail }]
          }

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Tests"

          assert_text "1 TEST FAILURE"
          assert_text "1 test failed"
        end
      end

      test "user views v1 test run" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)
        create :submission_test_run,
          submission:,
          ops_status: 200,
          raw_results: {
            version: 1,
            status: "fail",
            message: "Test 2 failed"
          }

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Tests"

          assert_text "TESTS FAILED"
        end
      end

      test "user views tests for submission on track with test runner disabled" do
        user = create :user
        track = create :track, has_test_runner: false
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :not_queued,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Tests"

          assert_text "This track does not support automatically running exercise tests."
        end
      end

      test "user views tests for submission on exercise with test runner disabled" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create :concept_exercise, track:, has_test_runner: false
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :not_queued,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Tests"

          assert_text "This exercise does not support automatically running its tests."
        end
      end

      test "user sees latest iteration" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create(:submission, solution:)
        create :iteration, solution:, submission:, idx: 1
        submission = create(:submission, solution:)
        create :iteration, solution:, submission:, idx: 2

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          within(".iteration", text: "Iteration 2") { assert_text "Latest" }
          within(".iteration", text: "Iteration 1") { refute_text "Latest" }
        end
      end
    end
  end
end
