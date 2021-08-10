require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class UserUnpublishesSolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user unpublishes a solution" do
        track = create :track
        exercise = create :concept_exercise, track: track
        author = create :user, handle: "author"
        create :user_track, user: author, track: track
        solution = create :concept_solution, :completed, :published, user: author, exercise: exercise
        submission = create :submission, solution: solution
        create :iteration, idx: 1, submission: submission
        submission = create :submission, solution: solution
        iteration_2 = create :iteration, idx: 2, submission: submission
        solution.update!(published_iteration: iteration_2)

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_url(track, exercise, "author")
          refute_button "1"

          click_on "Publish settings"
          click_on "Unpublish solution…"
          within(".m-unpublish-solution") { click_on "Unpublish solution" }

          assert_text "Publish your solution"
        end
      end

      test "user changes a published iteration via the comments options menu" do
        track = create :track
        exercise = create :concept_exercise, track: track
        author = create :user, handle: "author"
        create :user_track, user: author, track: track
        solution = create :concept_solution, :completed, :published, user: author, exercise: exercise
        submission = create :submission, solution: solution
        create :iteration, idx: 1, submission: submission
        submission = create :submission, solution: solution
        iteration_2 = create :iteration, idx: 2, submission: submission
        solution.update!(published_iteration: iteration_2)

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_url(track, exercise, "author")
          refute_button "1"

          within(".comments") { click_on "Options" }
          click_on "Unpublish solution…"
          within(".m-unpublish-solution") { click_on "Unpublish solution" }

          assert_text "Publish your solution"
        end
      end

      test "other user can not unpublish the solution" do
        track = create :track
        exercise = create :concept_exercise, track: track
        author = create :user, handle: "author"
        create :user_track, user: author, track: track
        solution = create :concept_solution, :completed, :published, user: author, exercise: exercise
        submission = create :submission, solution: solution
        create :iteration, idx: 1, submission: submission
        submission = create :submission, solution: solution
        iteration_2 = create :iteration, idx: 2, submission: submission
        solution.update!(published_iteration: iteration_2)

        use_capybara_host do
          sign_in!
          visit track_exercise_solution_url(track, exercise, "author")

          assert_no_button "Publish settings"
          within(".comments") { assert_no_button "Options" }
        end
      end
    end
  end
end
