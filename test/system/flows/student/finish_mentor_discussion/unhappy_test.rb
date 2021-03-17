require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module FinishesMentorDiscussion
      class UnhappyTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student is unhappy with mentor discussion and chooses to report" do
          user = create :user
          track = create :track
          exercise = create :practice_exercise, track: track
          solution = create :practice_solution, exercise: exercise, user: user
          submission = create :submission, solution: solution,
                                           tests_status: :passed,
                                           representation_status: :generated,
                                           analysis_status: :completed
          create :iteration, idx: 1, solution: solution, submission: submission
          request = create :solution_mentor_request, solution: solution
          discussion = create :solution_mentor_discussion, solution: solution, request: request

          use_capybara_host do
            sign_in!(user)
            visit finish_mentor_discussion_temp_modals_path(discussion_id: discussion.id)
            click_on "Unhappy"
            check "Report this discussion to an admin"
            fill_in "Message", with: "Bad mentor"
            click_on "Submit"
            click_on "Complete"

            assert_text "View mentoring request"
          end
        end
      end
    end
  end
end
