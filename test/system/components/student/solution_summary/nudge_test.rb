require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components
  module Student
    module SolutionSummary
      class NudgeTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "shows nudge when iteration tests failed" do
          user = create :user
          solution = create :practice_solution, user: user
          submission = create :submission, solution: solution, tests_status: :failed
          create :iteration, idx: 1, solution: solution, submission: submission

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)

            assert_text "Struggling with this exercise?"
            assert_link "Submit for Code Review",
              href: Exercism::Routes.new_track_exercise_mentor_request_path(solution.track, solution.exercise)
          end
        end

        test "hides nudge when mentorship is finished" do
          user = create :user
          mentor = create :user, handle: "Mentor"
          solution = create :practice_solution, user: user, mentoring_status: :finished
          submission = create :submission, solution: solution, tests_status: :passed
          create :iteration, idx: 1, solution: solution, submission: submission
          request = create :mentor_request, solution: solution, status: :fulfilled
          create :mentor_discussion,
            solution: solution,
            mentor: mentor,
            request: request,
            status: :finished
          solution.update_mentoring_status!

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)

            assert_no_text "Improve your solution with mentoring"
          end
        end

        test "shows nudge when mentorship requested" do
          user = create :user
          solution = create :practice_solution, user: user
          submission = create :submission, solution: solution, tests_status: :failed
          create :iteration, idx: 1, solution: solution, submission: submission
          create :mentor_request, solution: solution

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)

            assert_text "You've requested mentoring"
            assert_link "Open request",
              href: Exercism::Routes.track_exercise_mentor_request_path(solution.track, solution.exercise)
          end
        end

        test "shows nudge when mentorship in progress" do
          user = create :user
          mentor = create :user, handle: "Mentor"
          solution = create :practice_solution, user: user, mentoring_status: :in_progress
          submission = create :submission, solution: solution, tests_status: :failed
          create :iteration, idx: 1, solution: solution, submission: submission
          request = create :mentor_request, solution: solution, status: :fulfilled
          discussion = create :mentor_discussion,
            solution: solution,
            mentor: mentor,
            request: request,
            status: :awaiting_student
          solution.update_mentoring_status!

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)

            assert_text "You're being mentored by Mentor"
            assert_text "Your turn to respond"
            assert_link "Open discussion",
              href: Exercism::Routes.track_exercise_mentor_discussion_url(solution.track, solution.exercise, discussion)
          end
        end
      end
    end
  end
end
