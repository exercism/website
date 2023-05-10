require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Mentor
    class FinishDiscussionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "mentor finishes the session" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise:, user: student
        discussion = create(:mentor_discussion, solution:, mentor:)
        create(:iteration, solution:)
        create(:mentor_student_relationship, mentor:, student:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          click_on "End discussion"
          within(".m-generic-confirmation") { click_on "End discussion" }

          assert_text "You've finished your discussion with student-123."
        end
      end

      test "mentor chooses to mentor student again" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise:, user: student
        discussion = create(:mentor_discussion, :mentor_finished, solution:, mentor:)
        create(:iteration, solution:)
        create(:mentor_student_relationship, mentor:, student:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          within(".finished-wizard") do
            click_on "Change preferences"
            assert_text "Do you want to mentor student-123 again?", wait: 2

            click_on "Yes"

            assert_text "Add student-123 to your favorites?"
          end
        end
      end

      test "mentor chooses not to mentor student again" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise:, user: student
        discussion = create(:mentor_discussion, :mentor_finished, solution:, mentor:)
        create(:iteration, solution:)
        create(:mentor_student_relationship, mentor:, student:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          within(".finished-wizard") do
            click_on "Change preferences"
            assert_text "Do you want to mentor student-123 again?", wait: 2

            click_on "No"

            assert_text "You will not see future mentor requests from student-123."
          end
        end
      end

      test "mentor adds student as favorite" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise:, user: student
        discussion = create(:mentor_discussion, :mentor_finished, solution:, mentor:)
        create(:iteration, solution:)
        create(:mentor_student_relationship, mentor:, student:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)

          within(".finished-wizard") do
            click_on "Change preferences"
            assert_text "Do you want to mentor student-123 again?", wait: 2

            click_on "Yes"
            click_on "Add to favorites"

            assert_text "student-123 is one of your favorites"
          end
        end
      end

      test "mentor skips adding student as favorite" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise:, user: student
        discussion = create(:mentor_discussion, :mentor_finished, solution:, mentor:)
        create(:iteration, solution:)
        create(:mentor_student_relationship, mentor:, student:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          within(".finished-wizard") do
            click_on "Change preferences"
            assert_text "Do you want to mentor student-123 again?", wait: 2

            click_on "Yes"
            click_on "Skip"

            assert_text "Thanks for mentoring student-123."
          end
        end
      end

      test "mentor changes preferences" do
        mentor = create :user, handle: "author"
        student = create :user, handle: "student-123"
        exercise = create :concept_exercise
        solution = create :concept_solution, exercise:, user: student
        discussion = create(:mentor_discussion, :mentor_finished, solution:, mentor:)
        create(:iteration, solution:)
        create(:mentor_student_relationship, mentor:, student:)

        use_capybara_host do
          sign_in!(mentor)
          visit mentoring_discussion_path(discussion)
          within(".finished-wizard") do
            click_on "Change preferences"
            assert_text "Do you want to mentor student-123 again?", wait: 2

            click_on "No"
            click_on "Change preferences"

            assert_text "Do you want to mentor student-123 again?"
          end
        end
      end
    end
  end
end
