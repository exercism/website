require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class FinishMentorDiscussionTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "mentor finishes the session" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      exercise = create :concept_exercise
      solution = create :concept_solution, exercise: exercise, user: student
      discussion = create :solution_mentor_discussion,
        solution: solution,
        mentor: mentor,
        requires_mentor_action_since: 1.day.ago
      create :iteration, solution: solution
      create :mentor_student_relationship, mentor: mentor, student: student

      use_capybara_host do
        sign_in!(mentor)
        visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        click_on "End discussion"
        within(".finish-mentor-discussion-modal") { click_on "End discussion" }

        assert_text "You've finished your discussion with student."
      end
    end

    test "mentor chooses to mentor student again" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      exercise = create :concept_exercise
      solution = create :concept_solution, exercise: exercise, user: student
      discussion = create :solution_mentor_discussion,
        solution: solution,
        mentor: mentor,
        requires_mentor_action_since: 1.day.ago
      create :iteration, solution: solution
      create :mentor_student_relationship, mentor: mentor, student: student

      use_capybara_host do
        sign_in!(mentor)
        visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        click_on "End discussion"
        within(".finish-mentor-discussion-modal") { click_on "End discussion" }
        click_on "Yes"

        assert_text "Add student to your favorites?"
      end
    end

    test "mentor chooses not to mentor student again" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      exercise = create :concept_exercise
      solution = create :concept_solution, exercise: exercise, user: student
      discussion = create :solution_mentor_discussion,
        solution: solution,
        mentor: mentor,
        requires_mentor_action_since: 1.day.ago
      create :iteration, solution: solution
      create :mentor_student_relationship, mentor: mentor, student: student

      use_capybara_host do
        sign_in!(mentor)
        visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        click_on "End discussion"
        within(".finish-mentor-discussion-modal") { click_on "End discussion" }
        click_on "No"

        assert_text "Thanks for mentoring."
      end
    end

    test "mentor adds student as favorite" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      exercise = create :concept_exercise
      solution = create :concept_solution, exercise: exercise, user: student
      discussion = create :solution_mentor_discussion,
        solution: solution,
        mentor: mentor,
        requires_mentor_action_since: 1.day.ago
      create :iteration, solution: solution
      create :mentor_student_relationship, mentor: mentor, student: student

      use_capybara_host do
        sign_in!(mentor)
        visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        click_on "End discussion"
        within(".finish-mentor-discussion-modal") { click_on "End discussion" }
        click_on "Yes"
        within(".finish-mentor-discussion-modal") { click_on "Add to favorites" }

        assert_text "student is one of your favorites"
      end
    end

    test "mentor skips adding student as favorite" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      exercise = create :concept_exercise
      solution = create :concept_solution, exercise: exercise, user: student
      discussion = create :solution_mentor_discussion,
        solution: solution,
        mentor: mentor,
        requires_mentor_action_since: 1.day.ago
      create :iteration, solution: solution
      create :mentor_student_relationship, mentor: mentor, student: student

      use_capybara_host do
        sign_in!(mentor)
        visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        click_on "End discussion"
        within(".finish-mentor-discussion-modal") { click_on "End discussion" }
        click_on "Yes"
        within(".finish-mentor-discussion-modal") { click_on "Skip" }

        assert_text "Thanks for mentoring."
      end
    end

    test "mentor changes preferences" do
      mentor = create :user, handle: "author"
      student = create :user, handle: "student"
      exercise = create :concept_exercise
      solution = create :concept_solution, exercise: exercise, user: student
      discussion = create :solution_mentor_discussion,
        solution: solution,
        mentor: mentor,
        requires_mentor_action_since: 1.day.ago
      create :iteration, solution: solution
      create :mentor_student_relationship, mentor: mentor, student: student

      use_capybara_host do
        sign_in!(mentor)
        visit test_components_mentoring_discussion_path(discussion_id: discussion.id)
        click_on "End discussion"
        within(".finish-mentor-discussion-modal") { click_on "End discussion" }
        click_on "No"
        click_on "Change preferences"

        assert_text "Want to mentor student again?"
      end
    end
  end
end
