require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"
require_relative "../../../../support/redirect_helpers"

module Flows
  module Student
    module FinishesMentorDiscussion
      class SatisfiedTest < ApplicationSystemTestCase
        include CapybaraHelpers
        include RedirectHelpers

        test "student is satisfied with mentor discussion and doesn't requeue" do
          user = create :user
          track = create :track
          create :user_track, user: user, track: track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, exercise: exercise, user: user
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :generated,
            analysis_status: :completed
          create :iteration, idx: 1, solution: solution, submission: submission
          discussion = create :mentor_discussion, solution: solution

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
            click_on "End discussion"
            within(".m-confirm-finish-student-mentor-discussion") { click_on "Review and end discussion" }
            click_on "Acceptable"
            click_on "No thanks"

            wait_for_redirect
            assert_text "Nice, it looks like you're done here!"
          end
        end

        test "student is satisfied with mentor discussion and chooses to requeue" do
          user = create :user
          track = create :track
          create :user_track, user: user, track: track
          exercise = create :practice_exercise, track: track
          solution = create :practice_solution, exercise: exercise, user: user
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :generated,
            analysis_status: :completed
          create :iteration, idx: 1, solution: solution, submission: submission
          request = create :mentor_request, solution: solution
          discussion = create :mentor_discussion, solution: solution, request: request

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
            click_on "End discussion"
            within(".m-confirm-finish-student-mentor-discussion") { click_on "Review and end discussion" }
            click_on "Acceptable"
            click_on "Yes please"
            click_on "Go back to your solution"

            assert_text "View mentoring request"
          end
        end
      end
    end
  end
end
