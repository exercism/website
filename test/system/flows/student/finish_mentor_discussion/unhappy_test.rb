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
          create(:user_track, user:, track:)
          exercise = create(:practice_exercise, track:)
          solution = create(:practice_solution, exercise:, user:)
          submission = create :submission, solution:,
            tests_status: :passed,
            representation_status: :generated,
            analysis_status: :completed
          create(:iteration, idx: 1, solution:, submission:)
          request = create(:mentor_request, solution:)
          discussion = create(:mentor_discussion, solution:, request:)

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
            click_on "End discussion"
            within(".m-confirm-finish-student-mentor-discussion") { click_on "Review and end discussion" }
            click_on "Problematic"
            find('label', text: "Report this discussion to an admin").click
            fill_in "What went wrong?", with: "Bad mentor"
            click_on "Code of Conduct violation"
            find("label", text: "Wrong or misleading information").click
            click_on "Finish"
            click_on "Go back to your solution"

            assert_equal :finished, discussion.reload.status
            assert_text "View mentoring request"
          end
        end
      end
    end
  end
end
