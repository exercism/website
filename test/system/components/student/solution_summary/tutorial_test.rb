require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Components
  module Student
    class TutorialTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "shows completion text for no feedback" do
        user = create :user
        track = create :track
        create(:user_track, track:, user:)
        hello_world = create :practice_exercise, slug: "hello-world"
        solution = create :concept_solution, user:, exercise: hello_world
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.no_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Exercise Solved"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "shows completion nudge for non actionable feedback" do
        user = create :user
        track = create :track
        create(:user_track, track:, user:)
        hello_world = create :practice_exercise, slug: "hello-world"
        solution = create :concept_solution, user:, exercise: hello_world
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.no_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Exercise Solved"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end
    end
  end
end
