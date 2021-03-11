require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentRequestsMentorship < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student requests mentorship" do
      user = create :user
      track = create :track
      exercise = create :concept_exercise, track: track
      solution = create :concept_solution, exercise: exercise, user: user
      submission = create :submission, solution: solution
      create :iteration, submission: submission, solution: solution
      create :submission_file, submission: submission, content: "class Bob\nend", filename: "bob.rb"

      use_capybara_host do
        sign_in!(user)
        visit new_track_exercise_mentor_request_url(track, exercise)

        fill_in "What are you hoping to learn from this track?", with: "I want to learn OOP."
        fill_in "How can a mentor help you with this solution?", with: "I don't know."
        click_on "Submit mentoring request"
      end

      assert_text "Waiting on a mentor..."
      assert_text "I don't know."
    end
  end
end
