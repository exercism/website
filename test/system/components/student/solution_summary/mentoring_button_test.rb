require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components
  module Student
    module SolutionSummary
      class MentoringButtonTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "shows discussions" do
          user = create :user
          mentor = create :user, handle: "my-mentor"
          solution = create :practice_solution, user: user
          request = create :mentor_request, solution: solution
          discussion = create :mentor_discussion, request: request, solution: solution, mentor: mentor
          request.fulfilled!
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :generated,
            analysis_status: :completed
          create :iteration, idx: 1, solution: solution, submission: submission
          create :user_track, user: user, track: solution.track

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)
            within(".mentoring") { find(".--dropdown-segment").click }

            assert_link "Continue code review",
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
          create :user_track, user: user, track: solution.track

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)
            within(".mentoring") { find(".--dropdown-segment").click }

            assert_link "Submit for Code Review"
            assert_text "Want to get mentored by a friend?"
          end
        end

        test "shows prompt again if mentoring finished" do
          # TODO: Implement this so that once mentoring is done:
          # 1. Don't show prompt
          # 2. Do show option in the normal place to request
          skip

          user = create :user
          mentor = create :user, handle: "my-mentor"
          solution = create :practice_solution, user: user
          request = create :mentor_request, solution: solution
          discussion = create :mentor_discussion,
            request: request,
            solution: solution,
            mentor: mentor,
            finished_at: Time.current
          request.fulfilled!
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :generated,
            analysis_status: :completed
          create :iteration, idx: 1, solution: solution, submission: submission
          solution.update_mentoring_status!
          create :user_track, user: user, track: solution.track

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)
            assert_css(".mentoring-discussion-nudge")

            assert_link "Submit for Code Review"
            assert_link "my-mentor",
              href: Exercism::Routes.track_exercise_mentor_discussion_path(solution.track, solution.exercise, discussion.uuid)
          end
        end

        test "shows links to submit for code review within nudge section" do
          user = create :user
          solution = create :practice_solution, user: user
          submission = create :submission, solution: solution,
            tests_status: :passed,
            representation_status: :generated,
            analysis_status: :completed
          create :iteration, idx: 1, solution: solution, submission: submission
          create :user_track, user: user, track: solution.track

          use_capybara_host do
            sign_in!(user)
            visit Exercism::Routes.private_solution_path(solution)
            within(".mentoring-prompt-nudge") { find(".--dropdown-segment").click }

            assert_link "Submit for Code Review"
            assert_text "Want to get mentored by a friend?"
          end
        end
      end
    end
  end
end
