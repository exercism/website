require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class UserEnablesSolutionCommentsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "solution author enables comments" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: false
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)
          within(".comments") { click_on "Options" }
          click_on "Enable comments"
          within(".m-generic-confirmation") { click_on "Enable comments" }

          assert_text "0 comments"
          assert_css ".c-markdown-editor"
        end
      end

      test "solution author disables comments" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: true
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)
          within(".comments") { click_on "Options" }
          click_on "Disable comments"
          within(".m-generic-confirmation") { click_on "Disable comments" }

          assert_text "You have disabled comments on this solution"
          assert_no_css ".c-markdown-editor"
        end
      end
    end
  end
end
