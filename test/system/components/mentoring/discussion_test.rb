require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"
require_relative "../../../support/markdown_editor_helpers"

module Components
  module Mentoring
    class DiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers
      include MarkdownEditorHelpers

      test "shows solution information" do
        mentor = create :user
        student = create :user, handle: "student"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        create :iteration, idx: 1, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        assert_css "img[src='#{solution.track.icon_url}'][alt='icon for Ruby track']"
        assert_css "img[src='#{student.avatar_url}']"\
          "[alt=\"Uploaded avatar of student\"]"
        assert_text "student"
        assert_text "on Running in Ruby"
      end

      test "shows representer feedback" do
        mentor = create :user
        student = create :user, handle: "student"
        create :user, name: "Feedback Author", reputation: 50
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, idx: 1, solution: solution
        submission = create :submission,
          solution: solution,
          iteration: iteration,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        author = create :user, name: "Feedback author"
        create :exercise_representation,
          exercise: running,
          source_submission: submission,
          feedback_author: author,
          feedback_markdown: "Good job",
          feedback_type: :essential,
          ast_digest: "AST"
        create :submission_representation,
          submission: submission,
          ast_digest: "AST"
        create :submission_file, submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Student received automated feedback"
        end

        assert_text "Feedback author gave this feedback on a solution very similar to yours"
        assert_text "Good job"
      end

      test "shows analyzer feedback" do
        mentor = create :user
        student = create :user, handle: "student"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, idx: 1, solution: solution
        submission = create :submission, solution: solution, iteration: iteration, analysis_status: :completed
        create :submission_analysis, submission: submission, data: {
          comments: [
            { type: "essential", comment: "ruby.two-fer.splat_args" }
          ]
        }

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Student received automated feedback"
        end

        assert_text "Our Ruby Analyzer has some comments on your solution"
        assert_text "Define an explicit"
      end

      test "shows posts" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        solution = create :concept_solution, user: student
        request = create :mentor_request, solution: solution, comment_markdown: "Hello, Mentor",
                                          updated_at: 2.days.ago
        discussion = create :mentor_discussion, solution: solution, mentor: mentor, request: request
        submission = create :submission, solution: solution
        create :iteration, idx: 2, solution: solution, created_at: 1.week.ago, submission: submission
        submission = create :submission, solution: solution
        iteration = create :iteration, idx: 1, solution: solution, created_at: 1.week.ago, submission: submission
        create(:mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello, student",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        within(".discussion") { assert_text "Iteration 1" }
        assert_text "Iteration 1was submitted\n7d ago"
        assert_css "img[src='#{student.avatar_url}']"
        assert_text "Hello, Mentor"
        assert_text "student"
        assert_text "2d ago"
        assert_css "img[src='#{mentor.avatar_url}']"
        assert_css ".comments.unread", text: "2"
        assert_text "author"
        assert_text "Hello, student"
      end

      test "empty mentor request comment is hidden" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student"
        track = create :track
        exercise = create :concept_exercise, track: track
        solution = create :concept_solution, user: student, exercise: exercise
        request = create :mentor_request, :v2, solution: solution, comment_markdown: ""
        discussion = create :mentor_discussion, solution: solution, mentor: mentor, request: request
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        assert_no_css ".post"
      end

      test "shows iteration information" do
        mentor = create :user
        solution = create :concept_solution
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, tests_status: "failed", solution: solution
        iteration = create :iteration,
          idx: 1,
          solution: solution,
          created_at: Time.current - 2.days,
          submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        assert_text "Iteration 1"
        assert_text "Latest"
        assert_text "Submitted 2 days ago"
        assert_css ".c-iteration-processing-status", visible: false, text: "Failed"

        submission.update!(tests_status: :passed)
        assert_equal :no_automated_feedback, iteration.status.to_sym
        IterationChannel.broadcast!(iteration)
        assert_css ".c-iteration-processing-status", visible: false, text: "Passed"
      end

      test "shows files per iteration" do
        skip # This consistently fails in CI

        mentor = create :user
        ruby = create :track, slug: "ruby"
        bob = create :concept_exercise, track: ruby
        solution = create :concept_solution, exercise: bob
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        submission_1 = create :submission, solution: solution
        create :submission_file,
          submission: submission_1,
          content: "class Bob\nend",
          filename: "bob.rb"
        submission_2 = create :submission, solution: solution
        create :submission_file,
          submission: submission_2,
          content: "class Lasagna\nend",
          filename: "bob.rb"
        create :iteration, idx: 1, solution: solution, submission: submission_1
        create :iteration, idx: 2, solution: solution, submission: submission_2

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          assert_text "class Lasagna", wait: 2

          within('footer .iterations') { click_on "1" }
          assert_text "class Bob", wait: 2
        end
      end

      test "refetches when new post comes in" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        iteration = create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          create(:mentor_discussion_post,
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
        solution = create :concept_solution
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          wait_for_websockets
          find("form").click
          fill_in_editor "# Hello", within: ".comment-section"
          click_on "Send"
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello"
      end

      test "submit a new post after discussion is finished" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :mentor_discussion, solution: solution, mentor: mentor, status: :mentor_finished
        create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          wait_for_websockets
          click_on "still post."
          find("form").click
          fill_in_editor "# Hello", within: ".comment-section"
          click_on "Send"
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello"
      end

      test "edit an existing post" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        iteration = create :iteration, solution: solution, submission: submission
        create(:mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          find_all(".post").last.hover
          click_on "Edit"
          fill_in_editor "# Edited"
          click_on "Update"
        end

        assert_css "h3", text: "Edited"
        assert_no_css "h3", text: "Hello"
      end

      test "deletes an existing post" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        iteration = create :iteration, solution: solution, submission: submission
        create(:mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          find_all(".post").last.hover
          click_on "Edit"
          fill_in_editor ""
          accept_alert { click_on "Delete" }
        end

        assert_no_css "h3", text: "Hello"
      end

      test "user can't edit another's post" do
        student = create :user
        mentor = create :user, handle: "author"
        solution = create :concept_solution, user: student
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, solution: solution
        iteration = create :iteration, solution: solution, submission: submission
        create(:mentor_request, solution: solution)
        create(:mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
        end

        refute_text "Edit"
      end

      test "mentor marks discussion as nothing to do" do
        mentor = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        discussion = create :mentor_discussion,
          :awaiting_mentor,
          solution: solution,
          mentor: mentor
        create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Remove from Inbox"
        end

        assert_text "Loading"
        assert_no_text "Remove from Inbox"
      end

      test "mentor is unable to remove discussion from inbox if finished" do
        mentor = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        discussion = create :mentor_discussion,
          :mentor_finished,
          solution: solution,
          mentor: mentor
        create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        assert_no_text "Remove from Inbox"
      end

      test "mentor sees mentor notes" do
        TestHelpers.use_website_copy_test_repo!

        mentor = create :user, handle: "author"
        exercise = create :concept_exercise, slug: "lasagna"
        solution = create :concept_solution, exercise: exercise
        discussion = create :mentor_discussion,
          solution: solution,
          mentor: mentor,
          awaiting_mentor_since: 1.day.ago
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Guidance"
          click_on "Mentor notes"
          assert_text "These are notes for lasagna"
        end
      end

      test "mentor notes show by default on practice exercise" do
        TestHelpers.use_website_copy_test_repo!

        mentor = create :user, handle: "author"
        exercise = create :practice_exercise
        solution = create :practice_solution, exercise: exercise
        discussion = create :mentor_discussion,
          solution: solution,
          mentor: mentor,
          awaiting_mentor_since: 1.day.ago
        submission = create :submission, solution: solution
        create :iteration, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Guidance"

          assert_text "Do bob shizzle"
        end
      end

      test "mentor sees own solution" do
        mentor = create :user, handle: "mentor"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        mentor_solution = create :concept_solution, exercise: exercise, user: mentor # rubocop:disable Lint/UselessAssignment
        create :iteration, solution: mentor_solution
        discussion = create :mentor_discussion,
          solution: solution,
          mentor: mentor,
          awaiting_mentor_since: 1.day.ago
        create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Guidance"
          click_on "How you solved the exercise"

          assert_link "Your Solution", href: Exercism::Routes.track_exercise_iterations_url(exercise.track, exercise)
          assert_text "to Strings in Ruby"
        end
      end

      test "mentor sees guidance" do
        mentor = create :user, handle: "mentor"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        discussion = create :mentor_discussion,
          solution: solution,
          mentor: mentor,
          awaiting_mentor_since: 1.day.ago
        create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Guidance"

          assert_text exercise.exemplar_files.values.first
        end
      end
    end
  end
end
