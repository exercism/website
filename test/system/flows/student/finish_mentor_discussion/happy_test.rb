require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module FinishesMentorDiscussion
      class HappyTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student is happy with mentor discussion" do
          user = create :user
          track = create :track
          exercise = create :concept_exercise, track: track
          solution = create :concept_solution, exercise: exercise, user: user
          discussion = create :mentor_discussion, solution: solution

          use_capybara_host do
            sign_in!(user)
            visit finish_mentor_discussion_temp_modals_path(discussion_id: discussion.uuid)
            click_on "It was good!"
            fill_in "Leave #{discussion.mentor.handle} a testimonial (optional)", with: "Good mentor!"
            click_on "Finish"
            click_on "Complete"

            assert_text "You've completed the mentor discussion for this exercise"
          end
        end
      end
    end
  end
end
