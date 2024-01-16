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
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url, handle: "student"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        create(:iteration, idx: 1, solution:)

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
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url, handle: "student"
        create :user, :external_avatar_url, name: "Feedback Author", reputation: 50
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        iteration = create(:iteration, idx: 1, solution:)
        submission = create :submission,
          solution:,
          iteration:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        author = create :user, :external_avatar_url, name: "Feedback author"
        editor = create :user, :external_avatar_url, name: "Feedback editor"
        create :exercise_representation,
          exercise: running,
          source_submission: submission,
          feedback_author: author,
          feedback_editor: editor,
          feedback_markdown: "Good job",
          feedback_type: :essential,
          ast_digest: "AST"
        create :submission_representation,
          submission:,
          ast_digest: "AST"
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Student received automated feedback"
        end

        assert_text "Feedback author gave this feedback on a solution very similar to yours"
        assert_text "edited by Feedback editor"
        assert_text "Good job"
      end

      test "renders correctly if edited_by is missing" do
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url, handle: "student"
        create :user, :external_avatar_url, name: "Feedback Author", reputation: 50
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        iteration = create(:iteration, idx: 1, solution:)
        submission = create :submission,
          solution:,
          iteration:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        author = create :user, :external_avatar_url, name: "Feedback author"
        create :exercise_representation,
          exercise: running,
          source_submission: submission,
          feedback_author: author,
          feedback_markdown: "Good job",
          feedback_type: :essential,
          ast_digest: "AST"
        create :submission_representation,
          submission:,
          ast_digest: "AST"
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Student received automated feedback"
        end

        assert_text "Feedback author gave this feedback on a solution very similar to yours"
        refute_text "edited by Feedback editor"
        assert_text "Good job"
      end

      test "doesnt show edited by if author and editor are the same" do
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url, handle: "student"
        create :user, :external_avatar_url, name: "Feedback Author", reputation: 50
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        iteration = create(:iteration, idx: 1, solution:)
        submission = create :submission,
          solution:,
          iteration:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        author = create :user, :external_avatar_url, name: "Feedback author"
        editor = create :user, :external_avatar_url, name: "Feedback author"
        create :exercise_representation,
          exercise: running,
          source_submission: submission,
          feedback_author: author,
          feedback_editor: editor,
          feedback_markdown: "Good job",
          feedback_type: :essential,
          ast_digest: "AST"
        create :submission_representation,
          submission:,
          ast_digest: "AST"
        create(:submission_file, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Student received automated feedback"
        end

        assert_text "Feedback author gave this feedback on a solution very similar to yours"
        refute_text "edited by Feedback author"
        assert_text "Good job"
      end

      test "shows analyzer feedback" do
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url, handle: "student"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        iteration = create(:iteration, idx: 1, solution:)
        submission = create :submission, solution:, iteration:, analysis_status: :completed
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "essential", comment: "ruby.two-fer.splat_args" }
          ]
        }

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Student received automated feedback"
        end

        assert_text "Our Ruby Analyzer generated this feedback when analyzing your solution."
        assert_text "Define an explicit"
      end

      test "shows student info" do
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url, name: "Apprentice", handle: "student", reputation: 1500, bio: "I love things"
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        within(".student-info") do
          assert_text student.name
          assert_text student.handle.to_s
          assert_text student.bio
          assert_text student.formatted_reputation
          # assert_text "english, spanish" # TODO: Renable
          assert_css "img[src$='#{url_to_path(student.avatar_url)}']"
          assert_button "Add to favorites"
        end
      end

      test "remove student from favorites" do
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        create(:iteration, idx: 1, solution:, submission:)
        create :mentor_student_relationship, mentor:, student:, favorited: true

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)

          find_button("Favorited").hover
          click_on "Unfavorite?"

          assert_button "Add to favorites"
        end
      end

      test "add student to favorites" do
        mentor = create :user, :external_avatar_url
        student = create :user, :external_avatar_url
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        create(:iteration, idx: 1, solution:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)

          click_on "Add to favorites"

          assert_text "Favorited"
        end
      end

      test "shows posts" do
        mentor = create :user, :external_avatar_url, handle: "author"
        student = create :user, :external_avatar_url, handle: "student"
        solution = create :concept_solution, user: student
        request = create :mentor_request, solution:, comment_markdown: "Hello, Mentor",
          created_at: 5.days.ago, updated_at: 2.days.ago
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        create(:iteration, idx: 2, solution:, created_at: 1.week.ago, submission:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, idx: 1, solution:, created_at: 1.week.ago, submission:)
        create(:mentor_discussion_post,
          discussion:,
          iteration:,
          author: mentor,
          content_markdown: "Hello, student",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        within(".c-discussion-timeline") { assert_text "Iteration 1" }
        assert_text "Iteration 1was submitted 7d ago"
        assert_text "Hello, Mentor"
        assert_text "student"
        assert_text "5d ago"
        assert_css ".comments.unread", text: "2"
        assert_text "author"
        assert_text "Hello, student"

        assert_css "img[src$='#{url_to_path(mentor.avatar_url)}']"
        assert_css "img[src$='#{url_to_path(student.avatar_url)}']"
      end

      test "empty mentor request comment is hidden" do
        mentor = create :user, :external_avatar_url, handle: "author"
        student = create :user, :external_avatar_url, handle: "student"
        track = create :track
        exercise = create(:concept_exercise, track:)
        solution = create(:concept_solution, user: student, exercise:)
        request = create :mentor_request, :v2, solution:, comment_markdown: ""
        discussion = create(:mentor_discussion, solution:, mentor:, request:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        assert_no_css ".post"
      end

      test "shows iteration information" do
        mentor = create :user, :external_avatar_url
        solution = create :concept_solution, user: create(:user, :external_avatar_url)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, tests_status: "failed", solution:)
        iteration = create(:iteration,
          idx: 1,
          solution:,
          created_at: Time.current - 2.days,
          submission:)

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

        mentor = create :user, :external_avatar_url
        ruby = create :track, slug: "ruby"
        bob = create :concept_exercise, track: ruby
        solution = create :concept_solution, exercise: bob
        discussion = create(:mentor_discussion, solution:, mentor:)
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
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          assert_text "class Lasagna", wait: 2

          within('footer .iterations') { click_on "1" }
          assert_text "class Bob", wait: 2
        end
      end

      test "refetches when new post comes in" do
        mentor = create :user, :external_avatar_url, handle: "author"
        solution = create :concept_solution, user: create(:user, :external_avatar_url)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          create(:mentor_discussion_post,
            discussion:,
            iteration:,
            author: mentor,
            content_markdown: "Hello",
            updated_at: Time.current)
          2.times { wait_for_websockets }
          DiscussionPostListChannel.notify!(discussion)
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_text "author"
        assert_text "Hello"
      end

      test "submit a new post" do
        mentor = create :user, :external_avatar_url, handle: "author"
        solution = create :concept_solution, user: create(:user, :external_avatar_url)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          wait_for_websockets
          find("form").click
          fill_in_editor "# Hello", within: ".comment-section"
          click_on "Send"
        end

        assert_css "img[src$='#{url_to_path(mentor.avatar_url)}']"
        assert_text "author"
        assert_text "Hello"
      end

      test "submit a new post after discussion is finished" do
        mentor = create :user, :external_avatar_url, handle: "author"
        solution = create :concept_solution, user: create(:user, :external_avatar_url)
        discussion = create :mentor_discussion, solution:, mentor:, status: :mentor_finished
        create(:iteration, solution:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          wait_for_websockets
          click_on "still post."
          find("form").click
          fill_in_editor "# Hello", within: ".comment-section"
          click_on "Send"
        end

        assert_css "img[src$='#{url_to_path(mentor.avatar_url)}']"
        assert_text "author"
        assert_text "Hello"
      end

      test "edit an existing post" do
        mentor = create :user, :external_avatar_url, handle: "author"
        solution = create :concept_solution, user: create(:user, :external_avatar_url)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, solution:, submission:)
        create(:mentor_discussion_post,
          discussion:,
          iteration:,
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
        mentor = create :user, :external_avatar_url, handle: "author"
        solution = create :concept_solution, user: create(:user, :external_avatar_url)
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, solution:, submission:)
        create(:mentor_discussion_post,
          discussion:,
          iteration:,
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
        student = create :user, :external_avatar_url
        mentor = create :user, :external_avatar_url, handle: "author"
        solution = create :concept_solution, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        submission = create(:submission, solution:)
        iteration = create(:iteration, solution:, submission:)
        create(:mentor_request, solution:)
        create(:mentor_discussion_post,
          discussion:,
          iteration:,
          author: mentor)

        use_capybara_host do
          sign_in!(student)
          visit track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion)
        end

        refute_text "Edit"
      end

      test "mentor marks discussion as nothing to do" do
        mentor = create :user, :external_avatar_url, handle: "author"
        exercise = create :concept_exercise
        solution = create(:concept_solution, exercise:, user: create(:user, :external_avatar_url))
        discussion = create(:mentor_discussion,
          :awaiting_mentor,
          solution:,
          mentor:)
        create(:iteration, solution:)
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          assert_text "It's the student's turn…"
          click_on "It's the student's turn…"

          assert_text "Pass this discussion back to the student?"
          click_on "Cancel"

          assert_text "It's the student's turn…"
          click_on "It's the student's turn…"

          click_on "Continue"

          refute_text "It's the student's turn…"
        end
      end

      test "mentor is unable to remove discussion from inbox if finished" do
        mentor = create :user, :external_avatar_url, handle: "author"
        exercise = create :concept_exercise
        solution = create(:concept_solution, exercise:, user: create(:user, :external_avatar_url))
        discussion = create(:mentor_discussion,
          :mentor_finished,
          solution:,
          mentor:)
        create(:iteration, solution:)
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
        end

        assert_no_text "Remove from Inbox"
      end

      test "mentor sees exercise guidance" do
        TestHelpers.use_website_copy_test_repo!

        mentor = create :user, :external_avatar_url, handle: "author"
        exercise = create :concept_exercise, slug: "lasagna"
        solution = create(:concept_solution, exercise:, user: create(:user, :external_avatar_url))
        discussion = create :mentor_discussion,
          solution:,
          mentor:,
          awaiting_mentor_since: 1.day.ago
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Guidance"
          click_on "Exercise notes"
          assert_text "These are notes for lasagna"
          assert_link "Pull Request on GitHub", href: exercise.mentoring_notes_edit_url
        end
      end

      test "mentor notes show by default on practice exercise" do
        TestHelpers.use_website_copy_test_repo!

        mentor = create :user, :external_avatar_url, handle: "author"
        exercise = create :practice_exercise
        solution = create(:practice_solution, exercise:, user: create(:user, :external_avatar_url))
        discussion = create :mentor_discussion,
          solution:,
          mentor:,
          awaiting_mentor_since: 1.day.ago
        submission = create(:submission, solution:)
        create(:iteration, solution:, submission:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "Guidance"

          assert_text "Do bob shizzle"
        end
      end

      test "mentor sees own solution" do
        mentor = create :user, :external_avatar_url, handle: "mentor"
        exercise = create :concept_exercise
        solution = create(:concept_solution, exercise:, user: create(:user, :external_avatar_url))
        mentor_solution = create :concept_solution, exercise:, user: mentor
        create :iteration, solution: mentor_solution
        discussion = create :mentor_discussion,
          solution:,
          mentor:,
          awaiting_mentor_since: 1.day.ago
        create(:iteration, solution:)
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
    end
  end
end
