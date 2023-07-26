require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Flows
  module CommunitySolutions
    class UserViewsCommentsTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include MarkdownEditorHelpers

      test "user sees solution comments" do
        author = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: true
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)
        create :solution_comment,
          author:,
          content_markdown: "# Hello world",
          solution:,
          updated_at: 2.days.ago

        use_capybara_host do
          sign_in!
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)

          within(".comment") do
            assert_text "author"
            assert_css "h3", text: "Hello world"
            assert_text "2 days ago"
          end
        end
      end

      test "user adds a comment" do
        user = create :user, handle: "other-user"
        author = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: true
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)
          fill_in_editor "# Hello"
          click_on "Send"

          assert_text "1 comment"
          within(".comment") do
            assert_text "other-user"
            assert_css "h3", text: "Hello"
            assert_text "a few seconds ago"
          end
        end
      end

      test "user edits a comment" do
        author = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: true
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)
        create :solution_comment,
          author:,
          content_markdown: "# Hello world",
          solution:,
          updated_at: 2.days.ago

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)
          find_all(".comment").last.hover
          click_on "Edit"
          fill_in_editor "# Edited", within: ".comment"
          click_on "Update"

          within(".comment") { assert_css "h3", text: "Edited" }
        end
      end

      test "user deletes a comment" do
        author = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: true
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)
        create :solution_comment,
          author:,
          content_markdown: "# Hello world",
          solution:,
          updated_at: 2.days.ago

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)
          find_all(".comment").last.hover
          click_on "Edit"
          fill_in_editor "", within: ".comment"
          accept_alert { click_on "Delete" }

          assert_no_text "Hello world"
        end
      end

      test "user sees comments zero state" do
        author = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author, allow_comments: true
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)

          assert_text "No one has commented on this solution"
        end
      end
    end
  end
end
