require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class EndMentorDiscussionTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "mentor ends the session" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      exercise = create :concept_exercise
      solution = create :concept_solution, exercise: exercise, user: student
      discussion = create :solution_mentor_discussion,
        solution: solution,
        mentor: mentor,
        requires_mentor_action_since: 1.day.ago
      create :iteration, solution: solution

      use_capybara_host do
        sign_in!(mentor)
        visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        click_on "End session"
        within(".end-session-modal") { click_on "End session" }

        assert_text "You've ended your discussion with student."
      end
    end
  end
end
