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
      create(:user_dismissed_introducer, slug: "track-welcome-modal-#{track.slug}", user:)
      create(:user_track, user:, track:)
      hello_world = create :concept_exercise, track:, slug: "hello-world"

      # completed hello world
      create :concept_solution,
        exercise: hello_world,
        user:,
        completed_at: 2.days.ago,
        status: :completed

      # completed lasagna
      exercise = create :concept_exercise, track:, title: "Lasagna"
      solution = create :concept_solution, exercise:, user:, status: :completed, completed_at: 2.days.ago
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)

      stub_latest_track_forum_threads(track)

      use_capybara_host do
        sign_in!(user)
        visit track_url(track)
        first("button", text: "Select an exercise").click
        within(".m-select-exercise-for-mentoring") { click_on "Lasagna" }

        fill_in "What are you hoping to learn from this track?", with: "I want to learn OOP."
        fill_in "How can a mentor help you with this solution?", with: "I'm sorry but I have absolutely no idea."
        click_on "Submit mentoring request"
      end

      assert_text "Waiting on a mentor…"
      assert_text "I'm sorry but I have absolutely no idea."
    end

    test "form should be invalid when textarea value doesn't reach min length of 20 characters" do
      user = create :user
      track = create :track
      create(:user_dismissed_introducer, slug: "track-welcome-modal-#{track.slug}", user:)
      create(:user_track, user:, track:)
      hello_world = create :concept_exercise, track:, slug: "hello-world"

      # completed hello world
      create :concept_solution,
        exercise: hello_world,
        user:,
        completed_at: 2.days.ago,
        status: :completed

      # completed lasagna
      exercise = create :concept_exercise, track:, title: "Lasagna"
      solution = create :concept_solution, exercise:, user:, status: :completed, completed_at: 2.days.ago
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)

      stub_latest_track_forum_threads(track)

      use_capybara_host do
        sign_in!(user)
        visit track_url(track)
        first("button", text: "Select an exercise").click
        within(".m-select-exercise-for-mentoring") { click_on "Lasagna" }

        fill_in "What are you hoping to learn from this track?", with: "12345678901234567890"
        fill_in "How can a mentor help you with this solution?", with: "1234567890123456789"

        click_on "Submit mentoring request"

        assert_css('textarea#request-mentoring-form-track-objectives:valid')
        assert_css('textarea#request-mentoring-form-solution-comment:invalid')

        refute_text "Waiting on a mentor…"
        refute_text "12345678890123456789"

        fill_in "What are you hoping to learn from this track?", with: "1234567890123456789"
        fill_in "How can a mentor help you with this solution?", with: "12345678901234567890"

        click_on "Submit mentoring request"

        assert_css('textarea#request-mentoring-form-track-objectives:invalid')
        assert_css('textarea#request-mentoring-form-solution-comment:valid')

        refute_text "Waiting on a mentor…"
        refute_text "123456788901234567890"
      end
    end

    test "student can not request mentorship for hello-world" do
      user = create :user
      track = create :track
      create(:user_dismissed_introducer, slug: "track-welcome-modal-#{track.slug}", user:)
      create(:user_track, user:, track:)
      hello_world = create :concept_exercise, track:, slug: "hello-world"

      # completed hello world
      create :concept_solution,
        exercise: hello_world,
        user:,
        completed_at: 2.days.ago,
        status: :completed

      # completed hello world
      exercise = create :concept_exercise, track:, slug: "lasagna"
      create :concept_solution,
        exercise:,
        user:,
        completed_at: 2.days.ago,
        status: :completed

      stub_latest_track_forum_threads(track)

      use_capybara_host do
        sign_in!(user)
        visit track_url(track)
        first("button", text: "Select an exercise").click

        within(".m-select-exercise-for-mentoring") { assert_no_text "Hello World" }
      end
    end

    test "student can not request mentorship for hello world" do
      user = create :user
      track = create :track
      create(:user_track, user:, track:)
      hello_world = create :concept_exercise, track:, slug: "hello-world"

      # completed hello world
      solution = create :concept_solution,
        exercise: hello_world,
        user:,
        completed_at: 2.days.ago,
        status: :completed
      create(:iteration, solution:)

      use_capybara_host do
        sign_in!(user)
        visit new_track_exercise_mentor_request_url(track, hello_world)

        assert_text "You've completed Hello World"
      end
    end

    test "student sees required number of completed exercises to request mentorship" do
      user = create :user
      track = create :track, title: "Ruby"
      create(:user_track, user:, track:)
      create :concept_exercise, track:, slug: "hello-world"

      stub_latest_track_forum_threads(track)

      use_capybara_host do
        sign_in!(user)
        visit track_url(track)

        assert_text 'Unlock mentoring for Ruby by completing ”Hello, World!”'
      end
    end

    test "student requests mentorship when slots are full" do
      user = create :user
      track = create :track
      create(:user_track, user:, track:)

      # slot 1
      exercise_1 = create :concept_exercise, track:, slug: "strings"
      solution_1 = create :concept_solution, user:, exercise: exercise_1
      create :mentor_discussion, solution: solution_1

      # slot 2
      exercise_2 = create :concept_exercise, track:, slug: "walking"
      solution_2 = create :concept_solution, user:, exercise: exercise_2
      create :mentor_discussion, solution: solution_2

      # slot 3
      exercise_3 = create :concept_exercise, slug: "running"
      create :concept_solution, user:, exercise: exercise_3

      use_capybara_host do
        sign_in!(user)
        visit new_track_exercise_mentor_request_url(track, exercise_3)

        assert_text "You have no more mentoring slots available."
      end
    end

    test "student edits empty comment" do
      user = create :user
      track = create :track
      create(:user_track, user:, track:)

      hello_world = create :concept_exercise, track:, slug: "hello-world"

      # completed hello world
      create :concept_solution,
        exercise: hello_world,
        user:,
        completed_at: 2.days.ago,
        status: :completed

      # completed lasagna
      exercise = create :concept_exercise, track:, title: "Lasagna"
      solution = create :concept_solution, exercise:, user:, status: :completed, completed_at: 2.days.ago
      create :mentor_request, :v2, solution:, comment_markdown: ""
      submission = create(:submission, solution:)
      create(:iteration, submission:, solution:)

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
