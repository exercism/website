require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class UserViewsSolutionWithCommentsDisabledTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "solution author views disabled comments" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: false
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)

          assert_text "You have disabled comments on this solution"
          assert_no_css ".c-markdown-editor"
        end
      end

      test "other user views disabled comments" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: false
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)

          assert_text "Comments have been disabled"
          assert_no_css ".c-markdown-editor"
        end
      end
    end
  end
end
