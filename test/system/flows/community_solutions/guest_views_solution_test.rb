require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Flows
  module CommunitySolutions
    class GuestViewsCommentsTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include MarkdownEditorHelpers

      test "views iterations per community solution" do
        user = create :user, handle: "handle"
        ruby = create :track, slug: "ruby"
        exercise = create :concept_exercise, track: ruby
        solution = create(:concept_solution, :published, published_at: 2.days.ago, exercise:, user:)
        submission_1 = create(:submission, solution:)
        create :submission_file,
          submission: submission_1,
          content: "class Bob\nend",
          filename: "bob.rb"
        submission_2 = create(:submission, solution:)
        create :submission_file,
          submission: submission_2,
          content: "class Lasagna\nend",
          filename: "bob.rb"
        create :iteration, idx: 1, solution:, submission: submission_1
        create :iteration, idx: 2, solution:, submission: submission_2

        use_capybara_host do
          visit track_exercise_solution_path(exercise.track, exercise, user.handle)
          assert_text "class Lasagna", wait: 2

          within("footer .iterations") { click_on "1" }
          refute_text "class Lasagna", wait: 2
          assert_text "class Bob", wait: 2
        end
      end

      test "views comments" do
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
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)

          within(".comment") do
            assert_text "author"
            assert_css "h3", text: "Hello world"
            assert_text "2 days ago"
          end
        end
      end

      test "cant write a comment" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, exercise:, user: author
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)

          assert_no_text "Write a comment"
        end
      end

      test "cant star a solution" do
        author = create :user
        exercise = create :concept_exercise
        solution = create :concept_solution, :published, published_at: 2.days.ago, exercise:, user: author
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)
        3.times { create :solution_star, solution: }

        use_capybara_host do
          visit track_exercise_solution_path(exercise.track, exercise, author.handle)

          within(".star-button") { assert_text "3" }

          assert_no_css "button.star-button"
        end
      end
    end
  end
end
