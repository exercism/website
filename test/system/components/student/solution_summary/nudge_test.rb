require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components
  module Student
    module SolutionSummary
      class NudgeTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "shows nudge when iteration tests failed" do
          # TODO: Cover this case
          skip
          user_track = create :user_track
          user = user_track.user
          solution = create(:practice_solution, user:)
          submission = create :submission, solution:, tests_status: :failed
          create(:iteration, idx: 1, solution:, submission:)

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
          solution = create :practice_solution, user:, mentoring_status: :finished
          submission = create :submission, solution:, tests_status: :passed
          create(:iteration, idx: 1, solution:, submission:)
          request = create :mentor_request, solution:, status: :fulfilled
          create :mentor_discussion,
            solution:,
            mentor:,
            request:,
            status: :finished
          solution.update_mentoring_status!

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)

            assert_no_text "Improve your solution with mentoring"
          end
        end

        test "shows nudge when mentorship requested" do
          user_track = create :user_track
          user = user_track.user
          solution = create(:practice_solution, user:)
          submission = create :submission, solution:, tests_status: :failed
          create(:iteration, idx: 1, solution:, submission:)
          create(:mentor_request, solution:)

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)

            assert_text "Code Review Requested"
            assert_link "View mentoring request",
              href: Exercism::Routes.track_exercise_mentor_request_path(solution.track, solution.exercise)
          end
        end

        test "shows nudge when mentorship in progress" do
          user_track = create :user_track
          user = user_track.user
          mentor = create :user, handle: "Mentor"
          solution = create :practice_solution, user:, mentoring_status: :in_progress
          submission = create :submission, solution:, tests_status: :failed
          create(:iteration, idx: 1, solution:, submission:)
          request = create :mentor_request, solution:, status: :fulfilled
          discussion = create :mentor_discussion,
            solution:,
            mentor:,
            request:,
            status: :awaiting_student
          solution.update_mentoring_status!

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)

            assert_text "Code Review In Progress"
            assert_text "It's your turn to respond"
            assert_link "Go to code review",
              href: track_exercise_mentor_discussion_path(user_track.track, solution.exercise, discussion)
          end
        end
      end
    end
  end
end
