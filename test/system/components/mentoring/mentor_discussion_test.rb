require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Components
  module Mentoring
    class MentorDiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers
      include MarkdownEditorHelpers

      test "shows correct information" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        refute_text "Student"
        assert_text "Hello"
      end

      test "refetches when new post comes in" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          create(:solution_mentor_discussion_post,
            discussion: discussion,
            iteration: iteration,
            author: mentor,
            content_markdown: "Hello",
            updated_at: Time.current)
          wait_for_websockets
          DiscussionPostListChannel.notify!(discussion, iteration)
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        refute_text "Student"
        assert_text "Hello"
      end

      test "submit a new post" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          wait_for_websockets
          click_on "Add a comment"
          fill_in_editor "# Hello"
          click_on "Send"
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        refute_text "Student"
        assert_text "Hello"
      end

      test "edit an existing post" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          click_on "Edit"
          fill_in_editor "# Edited"
          click_on "Send"
        end

        assert_css "h1", text: "Edited"
      end

      test "user can't edit another's post" do
        student = create :user
        mentor = create :user, handle: "author"
        solution = create :concept_solution, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor)

        use_capybara_host do
          sign_in!(student)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
        end

        refute_text "Edit"
      end

      test "mentor saves scratchpad page" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          click_on "Scratchpad"
          fill_in_editor "# Hello"
          assert_text "Unsaved"
          click_on "Save"
          assert_no_text "Unsaved"
        end
      end

      test "mentor sees scratchpad page" do
        mentor = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          click_on "Scratchpad"

          assert_editor_text "# Some notes"
          assert_no_text "Unsaved"
        end
      end

      test "mentor updates scratchpad page" do
        mentor = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          click_on "Scratchpad"
          fill_in_editor "# Hello"
          assert_text "Unsaved"
          click_on "Save"
          assert_no_text "Unsaved"
        end
      end

      test "mentor reverts scratchpad page" do
        mentor = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_mentor_discussion_path(
            discussion_id: discussion.id,
            iteration_id: iteration.id
          )
          click_on "Scratchpad"
          fill_in_editor "# Hello"
          click_on "Revert"
          assert_editor_text "# Some notes"
        end
      end
    end
  end
end
