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

          sleep(10)
          click_on "Continue"
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

          sleep(10)
          click_on "Continue"
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

          sleep(10)
          click_on "Continue"
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

          sleep(10)
          click_on "Continue"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      private
      def wait_for_submission
        assert_text "Running tests..."
      end
    end
  end
end
