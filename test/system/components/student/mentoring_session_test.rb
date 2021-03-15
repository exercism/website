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
        track = create :track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, user: student, exercise: exercise
        request = create :solution_mentor_request, solution: solution, comment_markdown: "Hello, Mentor",
                                                   updated_at: 2.days.ago
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor, request: request
        submission = create :submission, solution: solution
        iteration = create :iteration,
          idx: 1,
          solution: solution,
          created_at: Date.new(2016, 12, 25),
          submission: submission
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello, student",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
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
        track = create :track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, user: student, exercise: exercise
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        iteration = create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
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
        track = create :track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, user: student, exercise: exercise
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
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
        track = create :track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, user: student, exercise: exercise
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        iteration = create :iteration, solution: solution, submission: submission
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: student,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
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
          visit track_exercise_mentor_discussion_path(ruby, bob, discussion)
          click_on "1"
        end

        sleep(0.1)
        assert_text "class Bob"
      end

      test "shows session info" do
        student = create :user
        mentor = create :user, handle: "mentor"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, running, discussion)

          assert_css "img[src='#{ruby.icon_url}'][alt=\"icon for Ruby track\"]"
          assert_css "svg.c-exercise-icon"
          assert_text "You're being mentored by mentor on\nRunning"
        end
      end

      test "shows mentor info" do
        student = create :user
        mentor = create :user, name: "Mentor", handle: "mentor", reputation: 1500
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, running, discussion)
        end

        within(".mentor-info") do
          assert_text mentor.name
          assert_text mentor.handle.to_s
          assert_text mentor.bio
          assert_text mentor.reputation
          assert_text "15 previous sessions"
          assert_css "img[src='#{mentor.avatar_url}']"\
            "[alt=\"Uploaded avatar of mentor\"]"
        end
      end

      test "shows automated feedback" do
        mentor = create :user
        student = create :user
        feedback_author = create :user, name: "Feedback Author", reputation: 50
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        request = create :solution_mentor_request, solution: solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor, request: request
        submission = create :submission,
          solution: solution,
          analysis_status: :completed,
          representation_status: :generated
        create :iteration, idx: 1, solution: solution, submission: submission
        create :submission_representation, submission: submission, ast_digest: "ast"
        create :exercise_representation,
          exercise: running,
          source_submission: submission,
          feedback_markdown: "Exercise feedback",
          feedback_type: :essential,
          ast_digest: "ast",
          feedback_author: feedback_author

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, running, discussion)
          find("summary", text: "You received automated feedback").click
        end

        assert_text "Exercise feedback"
        assert_text "by Feedback Author"
        assert_css "img[src='#{feedback_author.avatar_url}']"
        assert_text "50"
      end
    end
  end
end
