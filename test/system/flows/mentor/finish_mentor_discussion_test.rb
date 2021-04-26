require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Mentor
    class FinishMentorDiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "mentor finishes the session" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise, user: student
        discussion = create :mentor_discussion, solution: solution, mentor: mentor
        create :iteration, solution: solution
        create :mentor_student_relationship, mentor: mentor, student: student

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "End discussion"
          within(".m-finish-mentor-discussion") { click_on "End discussion" }

          assert_text "You've finished your discussion with student-123."
        end
      end

      test "mentor chooses to mentor student again" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise, user: student
        discussion = create :mentor_discussion, :mentor_finished, solution: solution, mentor: mentor, finished_at: 1.day.ago
        create :iteration, solution: solution
        create :mentor_student_relationship, mentor: mentor, student: student

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "Change preferences"

          sleep(0.1)
          click_on "Yes"
          sleep(0.1)

          assert_text "Add student-123 to your favorites?"
        end
      end

      test "mentor chooses not to mentor student again" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise, user: student
        discussion = create :mentor_discussion, :mentor_finished, solution: solution, mentor: mentor, finished_at: 1.day.ago
        create :iteration, solution: solution
        create :mentor_student_relationship, mentor: mentor, student: student

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "Change preferences"

          sleep(0.1)
          click_on "No"
          sleep(0.1)

          assert_text "You will not see future mentor requests from student-123."
        end
      end

      test "mentor adds student as favorite" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise, user: student
        discussion = create :mentor_discussion, :mentor_finished, solution: solution, mentor: mentor, finished_at: 1.day.ago
        create :iteration, solution: solution
        create :mentor_student_relationship, mentor: mentor, student: student

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "Change preferences"
          sleep(0.1)
          click_on "Yes"
          sleep(0.1)
          within(".finished-wizard") { click_on "Add to favorites" }

          assert_text "student-123 is one of your favorites"
        end
      end

      test "mentor skips adding student as favorite" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise, user: student
        discussion = create :mentor_discussion, :mentor_finished, solution: solution, mentor: mentor, finished_at: 1.day.ago
        create :iteration, solution: solution
        create :mentor_student_relationship, mentor: mentor, student: student

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "Change preferences"
          sleep(0.1)
          click_on "Yes"
          sleep(0.1)
          click_on "Skip"

          assert_text "Thanks for mentoring student-123."
        end
      end

      test "mentor changes preferences" do
        skip # TODO: This fails all the time. Fix before launch.

        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise: exercise, user: student
        discussion = create :mentor_discussion, solution: solution, mentor: mentor, finished_at: 1.day.ago
        create :iteration, solution: solution
        create :mentor_student_relationship, mentor: mentor, student: student

        use_capybara_host do
          sign_in!(mentor)
          visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
          click_on "Change preferences"
          sleep(0.1)
          click_on "No"
          sleep(0.1)
          click_on "Change preferences"

          assert_text "Want to mentor student-123 again?"
        end
      end
    end
  end
end
