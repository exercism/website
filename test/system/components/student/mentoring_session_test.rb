require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Components
  module Student
    class MentoringSessionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers
      include MarkdownEditorHelpers

      test "shows posts" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        solution = create :concept_solution, user: student
        request = create :solution_mentor_request, solution: solution, comment: "Hello, Mentor", updated_at: 2.days.ago
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor, request: request
        iteration = create :iteration, idx: 1, solution: solution, created_at: Date.new(2016, 12, 25)
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello, student",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(student)
          visit test_components_student_mentoring_session_path(discussion_id: discussion.id)
        end

        within(".discussion") { assert_text "Iteration 1" }
        assert_text "Iteration 1\nwas submitted\n25 Dec 2016"
        assert_css "img[src='#{student.avatar_url}']"
        assert_text "Hello, Mentor"
        assert_text "student"
        assert_text "2 days ago"
        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello, student"
      end

      test "refetches when new post comes in" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        solution = create :concept_solution, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution

        use_capybara_host do
          sign_in!(student)
          visit test_components_student_mentoring_session_path(discussion_id: discussion.id)
          create(:solution_mentor_discussion_post,
            discussion: discussion,
            iteration: iteration,
            author: mentor,
            content_markdown: "Hello",
            updated_at: Time.current)
          wait_for_websockets
          DiscussionPostListChannel.notify!(discussion)
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello"
      end

      test "submit a new post" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        solution = create :concept_solution, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        create :iteration, solution: solution

        use_capybara_host do
          sign_in!(student)
          visit test_components_student_mentoring_session_path(discussion_id: discussion.id)
          wait_for_websockets
          click_on "Add a comment"
          fill_in_editor "# Hello", within: ".comment-section"
          click_on "Send"
        end

        assert_css "img[src='#{student.avatar_url}']"
        assert_text "student"
        assert_text "Hello"
      end

      test "edit an existing post" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        solution = create :concept_solution, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: student,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(student)
          visit test_components_student_mentoring_session_path(discussion_id: discussion.id)
          find_all(".post").last.hover
          click_on "Edit"
          fill_in_editor "# Edited"
          click_on "Send"
        end

        assert_css "h1", text: "Edited"
        assert_no_css "h1", text: "Hello"
      end

      test "shows files per iteration" do
        mentor = create :user
        student = create :user
        ruby = create :track, slug: "ruby"
        bob = create :concept_exercise, track: ruby
        solution = create :concept_solution, exercise: bob, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        submission_1 = create :submission, solution: solution
        create :submission_file,
          submission: submission_1,
          content: "class Bob\nend",
          filename: "bob.rb"
        submission_2 = create :submission, solution: solution
        create :iteration, idx: 1, solution: solution, submission: submission_1
        create :iteration, idx: 2, solution: solution, submission: submission_2

        use_capybara_host do
          sign_in!(student)
          visit test_components_student_mentoring_session_path(discussion_id: discussion.id)
          click_on "1"
        end

        assert_text "class Bob"
      end
    end
  end
end
