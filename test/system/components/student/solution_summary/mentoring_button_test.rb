require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components::Student
  module SolutionSummary
    class MentoringButtonTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows discussions" do
        user = create :user
        mentor = create :user, handle: "my-mentor"
        solution = create :practice_solution, user: user
        request = create :mentor_request, solution: solution
        discussion = create :mentor_discussion, request: request, solution: solution, mentor: mentor
        submission = create :submission, solution: solution,
                                         tests_status: :passed,
                                         representation_status: :generated,
                                         analysis_status: :completed
        create :iteration, idx: 1, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
          within(".mentoring") { find(".--dropdown-segment").click }

          assert_link "Continue mentoring",
            href: Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion.uuid)
          assert_link "my-mentor",
            href: Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion.uuid)
        end
      end

      test "shows links to request mentoring" do
        user = create :user
        solution = create :practice_solution, user: user
        submission = create :submission, solution: solution,
                                         tests_status: :passed,
                                         representation_status: :generated,
                                         analysis_status: :completed
        create :iteration, idx: 1, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
          within(".mentoring") { find(".--dropdown-segment").click }

          assert_link "Request mentoring"
          assert_text "Want to get mentored by a friend?"
        end
      end

      test "shows discussions within nudge section" do
        user = create :user
        mentor = create :user, handle: "my-mentor"
        solution = create :practice_solution, user: user
        request = create :mentor_request, solution: solution
        discussion = create :mentor_discussion, request: request, solution: solution, mentor: mentor
        submission = create :submission, solution: solution,
                                         tests_status: :passed,
                                         representation_status: :generated,
                                         analysis_status: :completed
        create :iteration, idx: 1, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
          within(".mentoring-nudge") { find(".--dropdown-segment").click }

          assert_link "Continue mentoring",
            href: Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion.uuid)
          assert_link "my-mentor",
            href: Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion.uuid)
        end
      end

      test "shows links to request mentoring within nudge section" do
        user = create :user
        solution = create :practice_solution, user: user
        submission = create :submission, solution: solution,
                                         tests_status: :passed,
                                         representation_status: :generated,
                                         analysis_status: :completed
        create :iteration, idx: 1, solution: solution, submission: submission

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
          within(".mentoring-nudge") { find(".--dropdown-segment").click }

          assert_link "Request mentoring"
          assert_text "Want to get mentored by a friend?"
        end
      end
    end
  end
end
