require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/markdown_editor_helpers"

module Flows
  class StudentRequestsMentorship < ApplicationSystemTestCase
    include CapybaraHelpers
    include MarkdownEditorHelpers

    test "student requests mentorship" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      hello_world = create :concept_exercise, track: track, slug: "hello-world"
      create :concept_solution,
        exercise: hello_world,
        user: user,
        completed_at: 2.days.ago,
        status: :completed
      exercise = create :concept_exercise, track: track, title: "Lasagna"
      solution = create :concept_solution, exercise: exercise, user: user, published_at: 1.day.ago, status: :published
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

    test "student edits empty comment" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track, title: "Lasagna"
      solution = create :concept_solution, exercise: exercise, user: user
      create :mentor_request, :v2, solution: solution, comment_markdown: ""
      submission = create :submission, solution: solution
      create :iteration, submission: submission, solution: solution

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_mentor_request_url(track, exercise)

        assert_text "Please update this comment to tell a mentor what you'd like to learn in this exercise"
        find_all(".post").last.hover
        click_on "Edit"
        fill_in_editor "# Edited"
        click_on "Update"
        assert_css "h3", text: "Edited"
      end
    end
  end
end
