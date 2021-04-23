require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module FinishesMentorDiscussion
      class SatisfiedTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student is satisfied with mentor discussion and doesn't requeue" do
          user = create :user
          track = create :track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, exercise: exercise, user: user
          discussion = create :mentor_discussion, solution: solution

          use_capybara_host do
            sign_in!(user)
            visit finish_mentor_discussion_temp_modals_path(discussion_id: discussion.uuid)
            click_on "Acceptable"
            click_on "No thanks"

            assert_text "You've completed the mentor discussion for this exercise"
          end
        end

        test "student is satisfied with mentor discussion and chooses to requeue" do
          user = create :user
          track = create :track
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
            visit finish_mentor_discussion_temp_modals_path(discussion_id: discussion.uuid)
            click_on "Acceptable"
            click_on "Yes please"
            click_on "Continue"

            assert_text "View mentoring request"
          end
        end
      end
    end
  end
end
