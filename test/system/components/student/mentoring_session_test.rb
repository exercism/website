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
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        request = create :mentor_request, solution:, comment_markdown: "Hello, Mentor",
          created_at: 2.weeks.ago
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        iteration = create(:iteration,
          idx: 1,
          solution:,
          created_at: 1.week.ago,
          submission:)
        create(:mentor_discussion_post,
          discussion:,
          iteration:,
          author: mentor,
          content_markdown: "Hello, student",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
        end

        within(".c-discussion-timeline") { assert_text "Iteration 1" }
        assert_text "Iteration 1was submitted 7d ago"
        assert_css "img[src='#{student.avatar_url}']"
        assert_text "Hello, Mentor"
        assert_text "student"
        assert_text "14d ago"
        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello, student"
      end

      test "deletes an existing post" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        request = create(:mentor_request, solution:)
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, solution:, submission:)
        create(:mentor_discussion_post,
          discussion:,
          iteration:,
          author: student,
          content_markdown: "How are you?")

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
          find_all(".post").last.hover
          click_on "Edit"
          fill_in_editor ""
          accept_alert { click_on "Delete" }
        end

        assert_no_css "h3", text: "How are you?"
      end

      test "refetches when new post comes in" do
        skip
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
          create(:mentor_discussion_post,
            discussion:,
            iteration:,
            author: mentor,
            content_markdown: "Hello",
            updated_at: Time.current)

          DiscussionPostListChannel.notify!(discussion)
          wait_for_websockets

          assert_css "img[src='#{mentor.avatar_url}']"
          assert_text "author"
          assert_text "Hello"
        end
      end

      test "submit a new post" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
          wait_for_websockets
          find("form").click
          fill_in_editor "# Hello", within: ".comment-section"
          click_on "Send"
        end

        assert_css "img[src='#{student.avatar_url}']"
        assert_text "student"
        assert_text "Hello"
      end

      test "edits first post" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        request = create :mentor_request, solution:, comment_markdown: "Hello"
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
          find_all(".post").last.hover
          click_on "Edit"
          fill_in_editor "# Edited"
          click_on "Update"
        end

        assert_css "h3", text: "Edited"
        assert_no_css "h3", text: "Hello"
      end

      test "empty mentor request comment is hidden" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        request = create :mentor_request, :v2, solution:, comment_markdown: ""
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
        end

        assert_no_css ".post"
      end

      test "user cant delete first post" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        request = create :mentor_request, solution:, comment_markdown: "Hello"
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
          find_all(".post").last.hover
          click_on "Edit"
          fill_in_editor ""
        end

        assert_no_button "Delete"
      end

      test "edit an existing post" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, solution:, submission:)
        create(:mentor_discussion_post,
          discussion:,
          iteration:,
          author: student,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(track, exercise, discussion)
          find_all(".post").last.hover
          click_on "Edit"
          fill_in_editor "# Edited"
          click_on "Update"
        end

        assert_css "h3", text: "Edited"
        assert_no_css "h3", text: "Hello"
      end

      test "shows files per iteration" do
        mentor = create :user
        student = create :user
        ruby = create :track, slug: "ruby"
        bob = create :concept_exercise, track: ruby
        solution = create :concept_solution, exercise: bob, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission_1 = create(:submission, solution:)
        create :submission_file,
          submission: submission_1,
          content: "class Bob\nend",
          filename: "bob.rb"
        submission_2 = create(:submission, solution:)
        create :iteration, idx: 1, solution:, submission: submission_1
        create :iteration, idx: 2, solution:, submission: submission_2

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, bob, discussion)
          click_on "1"

          assert_text "class Bob"
        end
      end

      test "shows session info" do
        student = create :user
        mentor = create :user, handle: "mentor"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, running, discussion)

          assert_css "img[src='#{ruby.icon_url}'][alt=\"icon for Ruby track\"]"
          assert_css "img.c-exercise-icon"
          assert_text "You're being mentored by mentor on Running"
        end
      end

      test "shows mentor info" do
        student = create :user
        mentor = create :user, name: "Mentor", handle: "mentor", reputation: 1500, bio: "I love to do a mentoring"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, running, discussion)
        end

        within(".mentor-info") do
          assert_text mentor.name
          assert_text mentor.handle.to_s
          assert_text mentor.bio
          assert_text mentor.formatted_reputation

          avatar_path = mentor.avatar_url.gsub("https://test.exercism.org", "")
          assert_css "img[src$='#{avatar_path}']"\
            "[alt=\"Uploaded avatar of mentor\"]"
        end
      end

      test "shows finished status when discussion is finished for student" do
        student = create :user
        mentor = create :user, name: "Mentor", handle: "mentor", reputation: 1500, bio: "I love to do a mentoring"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, :student_finished, solution:, mentor:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, running, discussion)

          assert_text "Ended"
        end
      end

      test "shows automated feedback" do
        skip # Readd when model is readded
        mentor = create :user
        student = create :user
        feedback_author = create :user, name: "Feedback Author", reputation: 50
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        request = create(:mentor_request, solution:)
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create :submission,
          solution:,
          analysis_status: :completed,
          representation_status: :generated
        create(:iteration, idx: 1, solution:, submission:)
        create :submission_representation, submission:, ast_digest: "ast"
        create(:exercise_representation,
          exercise: running,
          source_submission: submission,
          feedback_markdown: "Exercise feedback",
          feedback_type: :essential,
          ast_digest: "ast",
          feedback_author:)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(ruby, running, discussion)
          find("div", text: "You received automated feedback").click
        end

        assert_text "Exercise feedback"
        assert_text "by Feedback Author"
        assert_css "img[src='#{feedback_author.avatar_url}']"
        assert_text "50"
      end

      test "shows solution is out of date" do
        mentor = create :user
        student = create :user
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create :concept_solution, user: student, exercise:, git_important_files_hash: "outdated"
        request = create(:mentor_request, solution:)
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        Exercism.without_bullet do
          use_capybara_host do
            sign_in!(student)
            visit track_exercise_mentor_discussion_path(track, exercise, discussion)
          end
        end

        assert_text "Outdated"
      end
    end
  end
end
