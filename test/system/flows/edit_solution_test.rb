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
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob

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
          click_on "Continue without waiting"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "user submits code via results panel" do
        use_capybara_host do
          user = create :user
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob

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
          click_on "Continue without waiting"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "user tries to submit code immediately" do
        use_capybara_host do
          user = create :user
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob
          submission = create(:submission, solution:)
          create :submission_test_run,
            submission:,
            ops_status: 200,
            raw_results: {
              status: "pass",
              tests: [{ name: :test_a_name_given, status: :pass, output: "Hello" }]
            }

          sign_in!(user)
          visit edit_track_exercise_path(solution.track, solution.exercise)
          within(".lhs-footer") { click_on "Submit" }

          sleep(0.5)
          click_on "Continue without waiting"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "user tries to submits code after refresh" do
        use_capybara_host do
          user = create :user
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob

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
          click_on "Continue without waiting"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "feedback modal shows taking too long text" do
        use_capybara_host do
          user = create :user
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob

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

          assert_text "Checking for automated feedback…"
          assert_text "Continue without waiting"
          sleep(10)
          assert_text "Sorry, this is taking a little longer than expected."
        end
      end

      test "feedback modal finds no feedback then user asks for a code review" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution:,
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

          within(".lhs-footer") { click_on "Submit" }
          assert_text "Checking for automated feedback"
          sleep(1)
          submission.update!(representation_status: :generated, analysis_status: :completed)
          solution.reload
          Submission::TestRunsChannel.broadcast!(test_run)
          SolutionWithLatestIterationChannel.broadcast!(solution)
          refute_text "Checking for automated feedback"
          assert_text "No Immediate Feedback"
          click_on "Request code review"
          assert_text "What are you hoping to learn from this track?"

          input_1 = find("#request-mentoring-form-track-objectives")
          input_2 = find("#request-mentoring-form-solution-comment")

          solution_comment = "Help me make this more idiomatic"
          input_1.set("Help me get better at this track")
          input_2.set(solution_comment)

          click_on "Submit for code review"
          assert_text "You've submitted your solution for Code Review"
          assert_text "View your request"
        end
      end

      test "feedback modal shows when mentorship is in progress" do
        mentor = create :user, handle: "Mentor"
        user_track = create :user_track
        solution = create :concept_solution, user: user_track.user, track: user_track.track
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :queued,
          analysis_status: :queued
        create(:iteration, idx: 1, solution:, submission:)
        request = create :mentor_request, solution:, status: :fulfilled
        create :mentor_discussion,
          solution:,
          mentor:,
          request:,
          status: :awaiting_student
        solution.update_mentoring_status!

        use_capybara_host do
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
          within(".lhs-footer") { click_on "Submit" }
          assert_text "Checking for automated feedback"
          sleep(1)
          submission.update!(representation_status: :generated, analysis_status: :completed)
          solution.reload
          Submission::TestRunsChannel.broadcast!(test_run)
          SolutionWithLatestIterationChannel.broadcast!(solution)

          assert_text "You have a mentoring session active for this exercise."
        end
      end

      test "feedback modal shows celebratory feedback" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution:,
            tests_status: :passed,
            representation_status: :queued,
            analysis_status: :queued
          create :submission_analysis, submission:, data: {
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
          assert_text "We have some positive feedback for you! 🎉"
        end
      end

      test "feedback modal shows essential feedback" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution:,
            tests_status: :passed,
            representation_status: :queued,
            analysis_status: :queued
          create :submission_analysis, submission:, data: {
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
          assert_text "Here's an important suggestion on how to improve your code…"
        end
      end

      test "user reads essential feedback, goes back to exercise, revisits cached feedback by pressing submit button" do
        use_capybara_host do
          user_track = create :user_track
          solution = create :concept_solution, user: user_track.user, track: user_track.track
          submission = create :submission, solution:,
            tests_status: :passed,
            representation_status: :queued,
            analysis_status: :queued
          create :submission_analysis, submission:, data: {
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
          assert_text "Here's an important suggestion on how to improve your code…"
          click_on "Go back to editor"
          within(".lhs-footer") { click_on "Submit" }
          refute_text "Checking for automated feedback"
          assert_text "Essential"
          assert_text "Here's an important suggestion on how to improve your code…"
        end
      end

      test "user sees deep dive video" do
        use_capybara_host do
          user = create :user
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob
          deep_dive_youtube_id = 'yYnqweoy12'
          deep_dive_blurb = 'Explore 14 different ways to solve Bob.'
          create(:generic_exercise, slug: solution.exercise.slug, blurb: solution.exercise.blurb, source: solution.exercise.source,
            source_url: solution.exercise.source_url, deep_dive_youtube_id:, deep_dive_blurb:, status: solution.exercise.status)

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
          click_on "Continue without waiting"
          assert_text "Dig Deeper into Strings!"
          assert_text "Explore 14 different ways to solve Bob."
          click_on "Continue"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      test "user doesn't see deep dive video with multiple iterations " do
        use_capybara_host do
          user = create :user
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob
          create(:iteration, solution:)
          deep_dive_youtube_id = 'yYnqweoy12'
          deep_dive_blurb = 'Explore 14 different ways to solve Anagram.'
          create(:generic_exercise, slug: solution.exercise.slug, blurb: solution.exercise.blurb, source: solution.exercise.source,
            source_url: solution.exercise.source_url, deep_dive_youtube_id:, deep_dive_blurb:, status: solution.exercise.status)

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
          click_on "Continue without waiting"
          refute_text "Deep Dive into Strings!"
          wait_for_redirect
          assert_text "Iteration 2"
        end
      end

      test "user doesn't see already watched deep dive video" do
        use_capybara_host do
          user = create :user
          create(:user_auth_token, user:)
          bob = create :concept_exercise
          create :user_track, user:, track: bob.track
          solution = create :concept_solution, user:, exercise: bob
          deep_dive_youtube_id = 'yYnqweoy12'
          deep_dive_blurb = 'Explore 14 different ways to solve Anagram.'
          create(:generic_exercise, slug: solution.exercise.slug, blurb: solution.exercise.blurb, source: solution.exercise.source,
            source_url: solution.exercise.source_url, deep_dive_youtube_id:, deep_dive_blurb:, status: solution.exercise.status)
          create :user_watched_video, user: solution.user, video_provider: :youtube, video_id: deep_dive_youtube_id

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
          click_on "Continue without waiting"
          refute_text "Deep Dive into Strings!"
          wait_for_redirect
          assert_text "Iteration 1"
        end
      end

      private
      def wait_for_submission
        assert_text "Running tests…"
      end
    end
  end
end
