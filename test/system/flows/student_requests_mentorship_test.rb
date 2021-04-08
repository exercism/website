require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentRequestsMentorship < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student requests mentorship" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      hello_world = create :concept_exercise, track: track, slug: "hello-world"
      solution = create :concept_solution,
        exercise: hello_world,
        user: user,
        completed_at: 2.days.ago,
        status: :completed
      exercise = create :concept_exercise, track: track, title: "Lasagna"
      create :concept_solution, exercise: exercise, user: user, published_at: 1.day.ago, status: :published
      submission = create :submission, solution: solution
      create :iteration, submission: submission, solution: solution
      create :submission_file, submission: submission, content: "class Bob\nend", filename: "bob.rb"

      use_capybara_host do
        sign_in!(user)
        visit track_url(track)
        first("button", text: "Select an exercise").click
        click_on "Lasagna"

        fill_in "What are you hoping to learn from this track?", with: "I want to learn OOP."
        fill_in "How can a mentor help you with this solution?", with: "I don't know."
        click_on "Submit mentoring request"
      end

      assert_text "Waiting on a mentor..."
      assert_text "I don't know."
    end
  end
end
