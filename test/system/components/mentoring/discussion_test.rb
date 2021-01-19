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
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        create :iteration, idx: 1, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        end

        assert_css "img[src='#{solution.track.icon_url}'][alt='icon for Ruby track']"
        assert_css "img[src='#{student.avatar_url}']"\
          "[alt=\"Uploaded avatar of student\"]"
        assert_text "student"
        assert_text "on Running in Ruby"
      end

      test "shows student info" do
        mentor = create :user
        student = create :user, name: "Apprentice", handle: "student", reputation: 1500
        ruby = create :track, title: "Ruby"
        running = create :concept_exercise, title: "Running", track: ruby
        solution = create :concept_solution, exercise: running, user: student
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        create :iteration, idx: 1, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        end

        within(".student-info") do
          assert_text student.name
          assert_text "@#{student.handle}"
          assert_text student.bio
          # assert_text "english, spanish" # TODO: Renable
          assert_text student.reputation
          assert_text "15 previous sessions"
          assert_css "img[src='#{student.avatar_url}']"\
            "[alt=\"Uploaded avatar of student\"]"
          assert_button "Add to favorites"
        end
      end

      test "shows posts" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, idx: 1, solution: solution, created_at: Date.new(2016, 12, 25)
        create(:solution_mentor_discussion_post,
          discussion: discussion,
          iteration: iteration,
          author: mentor,
          content_markdown: "Hello",
          updated_at: Time.current)

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        end

        assert_css "img[src='#{mentor.avatar_url}']"
        assert_css ".comments.unread", text: "1"
        within(".discussion") { assert_text "Iteration 1" }
        assert_text "Iteration 1\nwas submitted\n25 Dec 2016"
        assert_text "author"
        refute_text "Student"
        assert_text "Hello"
      end

      test "shows iteration information" do
        mentor = create :user
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        submission = create :submission, tests_status: "failed"
        iteration = create :iteration, idx: 1, solution: solution, created_at: Time.current - 2.days, submission: submission

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        end

        assert_text "Iteration 1"
        assert_text "latest"
        assert_text "Submitted 2 days ago"
        assert_text "failed"

        submission.update!(tests_status: :passed)
        IterationChannel.broadcast!(iteration)
        assert_text "passed"
      end

      test "shows files per iteration" do
        mentor = create :user
        ruby = create :track, slug: "ruby"
        bob = create :concept_exercise, track: ruby
        solution = create :concept_solution, exercise: bob
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
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "1"
        end

        assert_text "class Bob"
      end

      test "refetches when new post comes in" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        iteration = create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
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
        refute_text "Student"
        assert_text "Hello"
      end

      test "submit a new post" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          wait_for_websockets
          click_on "Add a comment"
          fill_in_editor "# Hello", within: ".comment-section"
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
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          find(".post").hover
          click_on "Edit"
          fill_in_editor "# Edited"
          click_on "Send"
        end

        assert_css "h1", text: "Edited"
        assert_no_css "h1", text: "Hello"
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
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        end

        refute_text "Edit"
      end

      test "mentor saves scratchpad page" do
        mentor = create :user, handle: "author"
        solution = create :concept_solution
        discussion = create :solution_mentor_discussion, solution: solution, mentor: mentor
        create :iteration, solution: solution

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
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
        create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
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
        create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
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
        create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "Scratchpad"
          fill_in_editor "# Hello"
          click_on "Revert"
          assert_editor_text "# Some notes"
        end
      end

      test "mentor marks discussion as nothing to do" do
        mentor = create :user, handle: "author"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise
        discussion = create :solution_mentor_discussion,
          solution: solution,
          mentor: mentor,
          requires_mentor_action_since: 1.day.ago
        create :iteration, solution: solution
        create :scratchpad_page, content_markdown: "# Some notes", author: mentor, about: exercise

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "Mark as nothing to do"
        end

        assert_text "Loading"
        assert_no_text "Mark as nothing to do"
      end
    end
  end
end
