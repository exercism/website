require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/ace_helpers"
require_relative "../../support/redirect_helpers"

module Components
  module Flows
    class EditSolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include CodeMirrorHelpers
      include RedirectHelpers

      test "user submits code on broadcast timeout" do
        use_capybara_host do
          user = create :user
          create :user_auth_token, user: user
          bob = create :concept_exercise
          create :user_track, user: user, track: bob.track
          solution = create :concept_solution, user: user, exercise: bob

          sign_in!(user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          click_on "Run Tests"
          wait_for_submission
          2.times { wait_for_websockets }
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }
          create :submission_file, submission: Submission.last
          Submission::TestRunsChannel.broadcast!(test_run)
          within(".lhs-footer") { click_on "Submit" }

          sleep(0.5)
          click_on "Continue anyway"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "user submits code via results panel" do
        use_capybara_host do
          user = create :user
          create :user_auth_token, user: user
          bob = create :concept_exercise
          create :user_track, user: user, track: bob.track
          solution = create :concept_solution, user: user, exercise: bob

          sign_in!(user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          click_on "Run Tests"
          wait_for_submission
          2.times { wait_for_websockets }
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }
          create :submission_file, submission: Submission.last
          Submission::TestRunsChannel.broadcast!(test_run)
          within(".success-box") { click_on "Submit" }

          sleep(0.5)
          click_on "Continue anyway"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "user tries to submits code immediately" do
        use_capybara_host do
          user = create :user
          create :user_auth_token, user: user
          bob = create :concept_exercise
          create :user_track, user: user, track: bob.track
          solution = create :concept_solution, user: user, exercise: bob
          submission = create :submission, solution: solution
          create :submission_test_run,
            submission: submission,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }

          sign_in!(user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }

          sleep(0.5)
          click_on "Continue anyway"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "user tries to submits code after refresh" do
        use_capybara_host do
          user = create :user
          create :user_auth_token, user: user
          bob = create :concept_exercise
          create :user_track, user: user, track: bob.track
          solution = create :concept_solution, user: user, exercise: bob

          sign_in!(user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          click_on "Run Tests"
          wait_for_submission
          2.times { wait_for_websockets }
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }
          Submission::TestRunsChannel.broadcast!(test_run)
          assert_button "Submit", disabled: false

          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }

          sleep(0.5)
          click_on "Continue anyway"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "feedback modal shows taking too long text" do
        use_capybara_host do
          user = create :user
          create :user_auth_token, user: user
          bob = create :concept_exercise
          create :user_track, user: user, track: bob.track
          solution = create :concept_solution, user: user, exercise: bob

          sign_in!(user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          click_on "Run Tests"
          wait_for_submission
          2.times { wait_for_websockets }
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }
          Submission::TestRunsChannel.broadcast!(test_run)
          assert_button "Submit", disabled: false

          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }

          assert_text "Checking for automated feedback..."
          assert_text "Continue anyway"
          sleep(10)
          assert_text "Sorry, this is taking a little long."
        end
      end

      test "feedback modal shows there is no feedback suggests code review then visits mentoring link" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :queued,
            analysis_status: :queued

          sign_in!(user_track.user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }

          assert_button "Submit", disabled: false

          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }
          assert_text "Checking for automated feedback"
          sleep(1)
          submission.update!(representation_status: :generated, analysis_status: :completed)
          solution.reload
          Submission::TestRunsChannel.broadcast!(test_run)
          SolutionWithLatestIterationChannel.broadcast!(solution)
          refute_text "Checking for automated feedback"
          assert_text "There is no automated feedback for this exercise"
          assert_text "we recommend requesting a code review"
          click_on "Submit for a code review"
          assert_text "Take your solution to the next level"
        end
      end

      test "feedback modal shows celebratory feedback" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :queued,
            analysis_status: :queued
          create :submission_analysis, submission: submission, data: {
            comments: [
              { type: "informative", comment: "ruby.two-fer.splat_args" },
              { type: "celebratory", comment: "ruby.two-fer.splat_args" }
            ]
          }

          sign_in!(user_track.user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }

          assert_button "Submit", disabled: false

          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }
          assert_text "Checking for automated feedback"
          sleep(1)
          submission.update!(representation_status: :generated, analysis_status: :completed)
          solution.reload
          Submission::TestRunsChannel.broadcast!(test_run)
          SolutionWithLatestIterationChannel.broadcast!(solution)
          assert_text "We've found celebratory automated feedback! 🎉"
        end
      end

      test "feedback modal shows essential feedback" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :queued,
            analysis_status: :queued
          create :submission_analysis, submission: submission, data: {
            comments: [
              { type: "informative", comment: "ruby.two-fer.splat_args" },
              { type: "essential", comment: "ruby.two-fer.splat_args" }
            ]
          }

          sign_in!(user_track.user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }

          assert_button "Submit", disabled: false

          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }
          assert_text "Checking for automated feedback"
          sleep(1)
          submission.update!(representation_status: :generated, analysis_status: :completed)
          solution.reload
          Submission::TestRunsChannel.broadcast!(test_run)
          SolutionWithLatestIterationChannel.broadcast!(solution)
          assert_text "Essential"
          assert_text "We've found some automated feedback"
        end
      end

      test "user reads essential feedback, goes back to exercise, revisits cached feedback by pressing submit button" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :queued,
            analysis_status: :queued
          create :submission_analysis, submission: submission, data: {
            comments: [
              { type: "informative", comment: "ruby.two-fer.splat_args" },
              { type: "essential", comment: "ruby.two-fer.splat_args" }
            ]
          }

          sign_in!(user_track.user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          test_run = create :submission_test_run,
            submission: Submission.last,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }

          assert_button "Submit", disabled: false

          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }
          assert_text "Checking for automated feedback"
          sleep(1)
          submission.update!(representation_status: :generated, analysis_status: :completed)
          solution.reload
          Submission::TestRunsChannel.broadcast!(test_run)
          SolutionWithLatestIterationChannel.broadcast!(solution)
          assert_text "Essential"
          assert_text "We've found some automated feedback"
          click_on "Go back to editor"
          within(".lhs-footer") { click_on "Submit" }
          refute_text "Checking for automated feedback"
          assert_text "Essential"
          assert_text "We've found some automated feedback"
        end
      end

      private
      def wait_for_submission
        assert_text "Running tests..."
      end
    end
  end
end
