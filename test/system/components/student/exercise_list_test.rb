require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Components
  module Student
    class ExerciseListTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers
      include MarkdownEditorHelpers

      test "shows exercises" do
        user = create :user
        track = create :track
        create :concept_exercise, track:, title: "Lasagna"
        create(:user_track, track:, user:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercises_path(track)
        end

        assert_text "Lasagna"
      end

      test "searches exercises" do
        user = create :user
        track = create :track
        create :concept_exercise, track:, title: "Lasagna", slug: "lasagna"
        create :concept_exercise, track:, title: "Running", slug: "running"
        create(:user_track, track:, user:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercises_path(track)
          fill_in "Search by title", with: "Running"
        end

        assert_text "Running"
        assert_no_text "Lasagna"
      end

      test "applies url params to search" do
        user = create :user
        track = create :track
        lasagna = create :concept_exercise, track:, title: "Lasagna", slug: "lasagna"
        create :concept_exercise, track:, title: "Running", slug: "running"
        create(:user_track, track:, user:)
        solution = create(:concept_solution, exercise: lasagna, user:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)
        strings = create :concept_exercise, track:, title: "Strings", slug: "strings"
        solution = create(:concept_solution, exercise: strings, user:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercises_path(track, status: "in_progress", criteria: "La")
        end

        assert_text "Lasagna"
        assert_no_text "Running"
        assert_no_text "Strings"
      end

      test "filters exercises by status" do
        user = create :user
        track = create :track
        lasagna = create :concept_exercise, track:, title: "Lasagna", slug: "lasagna"
        create :concept_exercise, track:, title: "Running", slug: "running"
        create(:user_track, track:, user:)
        solution = create(:concept_solution, exercise: lasagna, user:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercises_path(track)
          click_on "In Progress"
        end

        assert_text "Lasagna"
        assert_no_text "Running"
      end
    end
  end
end
