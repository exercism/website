require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Student
    class MentorFinishedDiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "end discussion button does not show" do
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        request = create(:mentor_request, solution:)
        discussion = create(:mentor_discussion,
          status: :mentor_finished,
          solution:,
          request:)
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
        end

        assert_text "Ended"
      end

      test "student reviews discussion" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, idx: 1, solution:, submission:)
        discussion = create :mentor_discussion, solution:, status: :mentor_finished

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
          click_on "Review & finish discussion"
          assert_css ".m-confirm-finish-student-mentor-discussion"
          within(".m-confirm-finish-student-mentor-discussion") { click_on "Review and end discussion" }
          click_on "It was good!"
          fill_in "Leave #{discussion.mentor.handle} a testimonial (optional)", with: "Good mentor!"
          click_on "Finish"
          click_on "Continue without donating"

          assert_text "Nice, it looks like you're done here! "
        end
      end

      test "student reviews timed out discussion from discussion header" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, idx: 1, solution:, submission:)
        discussion = create(:mentor_discussion,
          status: :mentor_timed_out,
          finished_by: :mentor_timed_out,
          solution:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
          within("#panel-discussion") do
            refute_text "Review and end discussion"
            assert_text "Review discussion"
          end
          within(".discussion-header") do
            refute_text "Review & finish discussion"
            assert_text "Review discussion"
            click_on "Review discussion"
          end
          refute_css ".m-confirm-finish-student-mentor-discussion"
          assert_text "Your discussion timed out"
          click_on "It was good!"
          fill_in "Leave #{discussion.mentor.handle} a testimonial (optional)", with: "Good mentor!"
          click_on "Finish"
          click_on "Continue without donating"

          assert_text "Nice, it looks like you're done here!"
        end
      end

      test "student reviews timed out discussion from side-panel" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, idx: 1, solution:, submission:)
        discussion = create(:mentor_discussion,
          status: :mentor_timed_out,
          finished_by: :mentor_timed_out,
          solution:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
          within(".discussion-header") do
            refute_text "Review & finish discussion"
            assert_text "Review discussion"
          end
          within("#panel-discussion") do
            refute_text "Review and end discussion"
            assert_text "Review discussion"
            click_on "Review discussion"
          end
          assert_text "Your discussion timed out"
          click_on "It was good!"
          fill_in "Leave #{discussion.mentor.handle} a testimonial (optional)", with: "Good mentor!"
          click_on "Finish"
          click_on "Continue without donating"

          assert_text "Nice, it looks like you're done here!"
        end
      end

      test "student revisits reviewed timed out discussion" do
        user = create :user
        track = create :track
        create(:user_track, user:, track:)
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, exercise:, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        create(:iteration, idx: 1, solution:, submission:)
        discussion = create(:mentor_discussion,
          status: :finished,
          finished_by: :mentor_timed_out,
          solution:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
          within(".discussion-header") do
            refute_text "Review & finish discussion"
            refute_text "Review discussion"
            assert_text "Ended"
          end
          within("#panel-discussion") do
            refute_text "Review and end discussion"
            refute_text "Review discussion"
          end
        end
      end
    end
  end
end
