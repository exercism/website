require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"
require_relative "../../../../support/redirect_helpers"

module Flows
  module Student
    module FinishesMentorDiscussion
      class HappyTest < ApplicationSystemTestCase
        include CapybaraHelpers
        include RedirectHelpers

        test "student is happy with mentor discussion" do
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
          discussion = create(:mentor_discussion, solution:)

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
            click_on "End discussion"
            within(".m-confirm-finish-student-mentor-discussion") { click_on "Review and end discussion" }
            click_on "It was good!"
            fill_in "Leave #{discussion.mentor.handle} a testimonial (optional)", with: "Good mentor!"
            click_on "Finish"
            click_on "Continue without donating"

            assert_text "Finished with the exercise?"
          end
        end

        test "student is happy with mentor discussion but does not leave a testimonial" do
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
          discussion = create(:mentor_discussion, solution:)

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
            click_on "End discussion"
            within(".m-confirm-finish-student-mentor-discussion") { click_on "Review and end discussion" }
            click_on "It was good!"
            click_on "Skip"

            wait_for_redirect
            assert_text "Finished with the exercise?"
          end
        end
      end
    end
  end
end
