require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Student
    class StudentViewsSolutionIterationsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "opens and closes iterations as expected" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user

        submission_1 = create :submission, tests_status: :queued, solution: solution
        create :iteration, idx: 1, solution: solution, submission: submission_1
        create :submission_file, submission: submission_1

        submission_2 = create :submission, tests_status: :queued, solution: solution
        create :iteration, idx: 2, solution: solution, submission: submission_2
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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
        create :iteration, idx: 2, solution: solution, submission: submission
        create :submission_file, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          find("summary").click

          create :iteration, idx: 3, solution: solution
          SolutionChannel.broadcast!(solution)
          assert_equal find("details", text: "Iteration 3")['open'], "true"
        end
      end

      test "does not open newest iteration when there are iterations open" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        create :hello_world_solution, :completed, track: track, user: user

        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
        create :iteration, idx: 2, solution: solution, submission: submission
        create :submission_file, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          sleep(0.2) # Give the websockets time to attach

          create :iteration, idx: 3, solution: solution
          SolutionChannel.broadcast!(solution)

          assert_equal "false", find("details", text: "Iteration 3")['open']
        end
      end

      test "user sees zero state" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        create :concept_solution, exercise: exercise, user: user

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "You haven’t submitted any iterations yet."
        end
      end

      test "user starts exercise in zero state" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        create :concept_solution, exercise: exercise, user: user

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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, tests_status: :queued, solution: solution, submitted_via: :cli
        create :iteration, idx: 2, solution: solution, submission: submission
        create :submission_file, submission: submission, content: "class Bob\n"

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "class Bob"
        end
      end

      test "user views processing iteration" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, tests_status: :queued, solution: solution
        create :iteration, solution: solution, submission: submission
        create :submission_file, submission: submission

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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create :iteration, solution: solution, submission: submission
        create :submission_file, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "No auto suggestions? Try human mentoring."
        end
      end

      test "user views iteration with failed tests" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution, tests_status: :failed
        create :iteration, solution: solution, submission: submission
        create :submission_file, submission: submission

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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create :exercise_representation,
          exercise: exercise,
          source_submission: submission,
          feedback_author: author,
          feedback_markdown: "Good job",
          feedback_type: :essential,
          ast_digest: "AST"
        create :submission_representation,
          submission: submission,
          ast_digest: "AST"
        create :iteration, solution: solution, submission: submission
        create :submission_file, submission: submission

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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create :iteration, solution: solution, submission: submission
        create :submission_file, submission: submission
        create :submission_analysis, submission: submission, data: {
          comments: [
            { type: "essential", comment: "ruby.two-fer.splat_args" }
          ]
        }

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)

          assert_text "Our Ruby Analyzer has some comments on your solution"
          assert_text "Define an explicit"
        end
      end

      test "user views v3 test run" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create :iteration, solution: solution, submission: submission
        create :submission_test_run,
          submission: submission,
          ops_status: 200,
          raw_results: {
            version: 3,
            status: "fail",
            tests: [{ name: :test_no_name_given, status: :fail, task_id: 1 }]
          }

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_iterations_url(track, exercise)
          click_on "Tests"

          assert_text "2 / 3 TASKS COMPLETED"
        end
      end

      test "user views v2 test run" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create :iteration, solution: solution, submission: submission
        create :submission_test_run,
          submission: submission,
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
        end
      end

      test "user views v1 test run" do
        user = create :user
        track = create :track
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create :iteration, solution: solution, submission: submission
        create :submission_test_run,
          submission: submission,
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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :not_queued,
          representation_status: :generated,
          analysis_status: :completed
        create :iteration, solution: solution, submission: submission

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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track, has_test_runner: false
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution,
          tests_status: :not_queued,
          representation_status: :generated,
          analysis_status: :completed
        create :iteration, solution: solution, submission: submission

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
        create :user_track, user: user, track: track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, exercise: exercise, user: user
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission, idx: 1
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission, idx: 2

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
