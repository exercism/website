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
        user_track = create :user_track
        user = user_track.user
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
        user_track = create :user_track
        user = user_track.user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :queued
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.testing? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within ".latest-iteration-link" do
          assert_text "Processing"
        end
        assert_no_css "section.completion-nudge"
        assert_no_css "section.mentoring-prompt-nudge"
        assert_no_css "section.mentoring-request-nudge"
        assert_no_css "section.mentoring-discussion-nudge"
      end

      test "responds to websockets" do
        user_track = create :user_track
        user = user_track.user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :queued
        iteration = create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        within ".latest-iteration-link" do
          assert_text "Processing"
        end

        submission = create :submission, solution:, tests_status: :failed
        iteration.update!(submission:)
        IterationChannel.broadcast!(iteration)

        within ".latest-iteration-link" do
          assert_text "Failed"
        end
      end

      test "still works when websockets message is not sent" do
        skip
        # TODO: Implement refetching capability for LatestIterationLink
        user_track = create :user_track
        user = user_track.user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :queued
        iteration = create(:iteration, idx: 1, solution:, submission:)

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        within ".latest-iteration-link" do
          assert_text "Processing"
        end

        submission = create :submission, solution:, tests_status: :failed
        iteration.update!(submission:)

        within ".latest-iteration-link" do
          assert_text "Failed"
        end
      end

      test "Failed tests" do
        user_track = create :user_track
        user = user_track.user
        solution = create(:practice_solution, user:)
        submission = create :submission, solution:, tests_status: :failed
        iteration = create(:iteration, idx: 1, solution:, submission:)
        assert iteration.status.tests_failed? # Sanity

        use_capybara_host do
          sign_in!(user)
          visit Exercism::Routes.private_solution_path(solution)
        end

        assert_text "Iteration 1"
        within ".latest-iteration-link" do
          assert_text "Failed"
        end
      end

      test "No feedback Practice Exercise" do
        user_track = create :user_track
        user = user_track.user
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          refute_css ".--non-actionable"
          refute_css ".--actionable"
          refute_css ".--essential"
        end
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          refute_css ".--non-actionable"
          refute_css ".--actionable"
          refute_css ".--essential"
        end
      end

      test "Non actionable feedback (Practice Exercise)" do
        user_track = create :user_track
        user = user_track.user
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          assert_css ".--non-actionable"
        end
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          assert_css ".--non-actionable"
        end
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          assert_css ".--non-actionable"
        end
      end

      test "Actionable feedback (Practice Exercise)" do
        user_track = create :user_track
        user = user_track.user
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          assert_css ".--actionable"
          assert_css ".--non-actionable"
        end
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          within ".--actionable" do
            assert_text "3"
          end
          assert_css ".--non-actionable"
        end
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
        within ".latest-iteration-link" do
          assert_text "Passed"
          within ".--essential" do
            assert_text "3"
          end
          assert_css ".--non-actionable"
          assert_css ".--actionable"
        end
      end

      test "Mentoring requested" do
        user_track = create :user_track
        user = user_track.user
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

        assert_text "View mentoring request"
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

          assert_text "Code Review In Progress"
        end
      end
    end
  end
end
