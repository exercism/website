require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Student
    class SolutionSummarySectionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "No iteration" do
        user = create :user
        solution = create(:practice_solution, user:)

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        refute_css "section.latest-iteration"
      end

      test "Untested iteration" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :not_queued
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.untested? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        assert_no_css "section.latest-iteration header"
        assert_no_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Iteration with tests queued" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :queued
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.testing? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution is being processed…"
        end
        assert_no_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "responds to websockets" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :queued
        iteration = create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        within "section.latest-iteration header" do
          assert_text "Your solution is being processed…"
        end

        submission = create :submission, solution:, tests_status: :failed
        iteration.update!(submission:)
        SolutionChannel.broadcast!(solution)
        LatestIterationStatusChannel.broadcast!(solution)

        within "section.latest-iteration header" do
          assert_text "Your solution failed the tests"
        end
        assert_css ".mentoring-prompt-nudge.animate"
      end

      test "still works when websockets message is not sent" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :queued
        iteration = create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        within "section.latest-iteration header" do
          assert_text "Your solution is being processed…"
        end

        submission = create :submission, solution:, tests_status: :failed
        iteration.update!(submission:)

        within "section.latest-iteration header" do
          assert_text "Your solution failed the tests"
        end
        assert_css ".mentoring-prompt-nudge.animate"
      end

      test "Failed tests" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :failed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.tests_failed? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution failed the tests"
          assert_text "Hmmm, it looks like your solution isn't working"
          assert_css ".status.failed"
        end
        assert_no_css "section.completion-nudge"
        assert_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "No feedback Practice Exercise" do
        user = create :user
        solution = create(:practice_solution, user:)
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

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution looks great!"
          assert_text "Your solution passed the tests and we don't have any recommendations."
          assert_text "You might want to work with a mentor to make it even better."
          assert_css ".status.passed"
        end
        assert_no_css "section.completion-nudge"
        assert_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "No feedback (Concept Exercise)" do
        user_track = create :user_track
        solution = create :concept_solution, user: user_track.user, track: user_track.track
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.no_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user_track.user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution looks great!"
          assert_text "Your solution passed the tests and we don't have any recommendations."
          refute_text "mentor" # Keep this as a wide search so it doesn't go out of date
          assert_css ".status.passed"
        end

        assert_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Non actionable feedback (Practice Exercise)" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "informative", comment: "ruby.two-fer.splat_args" },
            { type: "celebratory", comment: "ruby.two-fer.splat_args" }
          ]
        }
        assert iteration.status.celebratory_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution looks great!"
          assert_text "We’ve analysed your solution and not found anything that needs changing."
          assert_text "We do have 2 additional comments that you might like to check."
          assert_text "Consider working with a mentor to make it even better."
          assert_css ".status.passed"
        end

        assert_no_css "section.completion-nudge"
        assert_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Non actionable feedback (Concept Exercise)" do
        user_track = create :user_track
        solution = create :concept_solution, user: user_track.user, track: user_track.track
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "informative", comment: "ruby.two-fer.splat_args" },
            { type: "informative", comment: "ruby.two-fer.splat_args" }
          ]
        }
        assert iteration.status.non_actionable_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user_track.user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution looks great!"
          assert_text "We’ve analysed your solution and not found anything that needs changing."
          assert_text "We do have 2 additional comments that you might like to check."
          refute_text "mentor" # Keep this as a wide search so it doesn't go out of date
          assert_css ".status.passed"
        end

        assert_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Celebratory feedback" do
        user_track = create :user_track
        solution = create :concept_solution, user: user_track.user, track: user_track.track
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "informative", comment: "ruby.two-fer.splat_args" },
            { type: "celebratory", comment: "ruby.two-fer.splat_args" }
          ]
        }
        assert iteration.status.celebratory_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user_track.user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution looks great!"
          assert_text "We’ve analysed your solution and not found anything that needs changing."
          assert_text "We do have 2 additional comments that you might like to check."
          refute_text "mentor" # Keep this as a wide search so it doesn't go out of date
          assert_css ".status.passed"
        end

        assert_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Actionable feedback (Practice Exercise)" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "actionable", comment: "ruby.two-fer.splat_args" },
            { type: "informative", comment: "ruby.two-fer.splat_args" },
            { type: "celebratory", comment: "ruby.two-fer.splat_args" }
          ]
        }
        assert iteration.status.actionable_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution worked, but you can take it further…"
          assert_text "We’ve analysed your solution and have 1 recommendation and 2 additional comments"
          assert_text "We suggest addressing the recommendation before proceeding."
          assert_css ".status.passed"
        end
        assert_no_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Actionable feedback (Concept Exercise)" do
        user_track = create :user_track
        solution = create :concept_solution, user: user_track.user, track: user_track.track
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "actionable", comment: "ruby.two-fer.splat_args" },
            { type: "actionable", comment: "ruby.two-fer.splat_args" },
            { type: "actionable", comment: "ruby.two-fer.splat_args" },
            { type: "informative", comment: "ruby.two-fer.splat_args" },
            { type: "celebratory", comment: "ruby.two-fer.splat_args" }
          ]
        }
        assert iteration.status.actionable_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user_track.user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution is good enough to continue!"
          assert_text "We’ve analysed your solution and have 3 recommendations and 2 additional comments"
          assert_text "You can either continue or address the recommendations first - your choice!"
          assert_css ".status.passed"
        end
        assert_no_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Essential feedback" do
        user_track = create :user_track
        solution = create :concept_solution, user: user_track.user, track: user_track.track
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        create :submission_analysis, submission:, data: {
          comments: [
            { type: "essential", comment: "ruby.two-fer.splat_args" },
            { type: "essential", comment: "ruby.two-fer.splat_args" },
            { type: "essential", comment: "ruby.two-fer.splat_args" },
            { type: "actionable", comment: "ruby.two-fer.splat_args" },
            { type: "informative", comment: "ruby.two-fer.splat_args" },
            { type: "celebratory", comment: "ruby.two-fer.splat_args" }
          ]
        }
        assert iteration.status.essential_automated_feedback? # Sanity

        use_capybara_host do
          sign_in!(user_track.user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within "section.latest-iteration header" do
          assert_text "Your solution worked, but you can take it further…"
          assert_text "We’ve analysed your solution and have 3 essential improvements, 1 recommendation and 2 additional comments"
          assert_text "Address the essential improvements before proceeding."
          assert_css ".status.passed"
        end
        assert_no_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Mentoring requested" do
        user = create :user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.no_automated_feedback? # Sanity
        create(:mentor_request, solution:)

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_no_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "Mentoring in-progress" do
        user = create :user

        solution = create(:practice_solution, user:)
        submission = create :submission, solution:,
          tests_status: :passed,
          representation_status: :generated,
          analysis_status: :completed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.no_automated_feedback? # Sanity

        create :user_track, user:, track: solution.track
        request = create(:mentor_request, solution:)
        create(:mentor_discussion, solution:, request:)
        request.fulfilled!

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)

          assert_no_css "section.completion-nudge"
          assert_no_css "section.mentoring-prompt-nudge"
          assert_no_css "section.mentoring-request-nudge"
          assert_css "section.mentoring-discussion-nudge"
        end
      end
    end
  end
end
