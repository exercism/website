require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components::Student
  class SolutionSummarySectionTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "No iteration" do
      user = create :user
      solution = create :practice_solution, user: user

      use_capybara_host do
        sign_in!(user)
        visit Exercism::Routes.private_solution_path(solution)
      end

      refute_css "section.latest-iteration"
    end

    test "Untested iteration" do
      user = create :user
      solution = create :practice_solution, user: user
      iteration = create :iteration, idx: 1, solution: solution
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
      assert_no_css "section.mentoring-nudge"
    end

    test "responds to websockets" do
      user = create :user
      solution = create :practice_solution, user: user
      iteration = create :iteration, idx: 1, solution: solution

      use_capybara_host do
        sign_in!(user)
        visit Exercism::Routes.private_solution_path(solution)
      end

      within "section.latest-iteration header" do
        assert_text "Your solution is being processed…"
      end

      submission = create :submission, solution: solution, tests_status: :failed
      iteration.update!(submission: submission)
      SolutionChannel.broadcast!(solution)

      within "section.latest-iteration header" do
        assert_text "Your solution failed the tests"
      end
    end

    test "Failed tests" do
      user = create :user
      solution = create :practice_solution, user: user
      submission = create :submission, solution: solution, tests_status: :failed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
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
      assert_no_css "section.mentoring-nudge"
    end

    test "No feedback Practice Exercise" do
      user = create :user
      solution = create :practice_solution, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
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
      within "section.mentoring-nudge" do
        assert_text "Improve your solution with mentoring"
      end
    end

    test "No feedback (Concept Exercise)" do
      user = create :user
      solution = create :concept_solution, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
      assert iteration.status.no_automated_feedback? # Sanity

      use_capybara_host do
        sign_in!(user)
        visit Exercism::Routes.private_solution_path(solution)
      end

      assert_text "Iteration 1"
      within "section.latest-iteration header" do
        assert_text "Your solution looks great!"
        assert_text "Your solution passed the tests and we don't have any recommendations."
        refute_text "mentor" # Keep this as a wide search so it doesn't go out of date
        assert_css ".status.passed"
      end
      within "section.completion-nudge" do
        assert_text "Hey, looks like you’re done here!"
      end
    end

    test "Non actionable feedback (Practice Exercise)" do
      user = create :user
      solution = create :practice_solution, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
      create :submission_analysis, submission: submission, data: {
        comments: [
          { type: "informative", comment: "ruby.two-fer.splat_args" },
          { type: "celebratory", comment: "ruby.two-fer.splat_args" }
        ]
      }
      assert iteration.status.non_actionable_automated_feedback? # Sanity

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
      within "section.mentoring-nudge" do
        assert_text "Improve your solution with mentoring"
      end
    end

    test "Non actionable feedback (Concept Exercise)" do
      user = create :user
      solution = create :concept_solution, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
      create :submission_analysis, submission: submission, data: {
        comments: [
          { type: "informative", comment: "ruby.two-fer.splat_args" },
          { type: "celebratory", comment: "ruby.two-fer.splat_args" }
        ]
      }
      assert iteration.status.non_actionable_automated_feedback? # Sanity

      use_capybara_host do
        sign_in!(user)
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
      within "section.completion-nudge" do
        assert_text "Hey, looks like you’re done here!"
      end
    end

    test "Actionable feedback (Practice Exercise)" do
      user = create :user
      solution = create :practice_solution, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
      create :submission_analysis, submission: submission, data: {
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
        assert_text "We suggest addressing the recommendations before proceeding."
        assert_css ".status.passed"
      end
      assert_no_css "section.completion-nudge"
      assert_no_css "section.mentoring-nudge"
    end

    test "Actionable feedback (Concept Exercise)" do
      user = create :user
      solution = create :concept_solution, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
      create :submission_analysis, submission: submission, data: {
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
        assert_text "Your solution is good enough to continue!"
        assert_text "We’ve analysed your solution and have 1 recommendation and 2 additional comments"
        assert_text "You can either continue or address the recommendations first - your choice!"
        assert_css ".status.passed"
      end
      assert_no_css "section.completion-nudge"
      assert_no_css "section.mentoring-nudge"
    end

    test "Essential feedback" do
      user = create :user
      solution = create :concept_solution, user: user
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      iteration = create :iteration, idx: 1, solution: solution, submission: submission
      create :submission_analysis, submission: submission, data: {
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
        sign_in!(user)
        visit Exercism::Routes.private_solution_path(solution)
      end

      assert_text "Iteration 1"
      within "section.latest-iteration header" do
        assert_text "Your solution worked, but you can take it further…"
        assert_text "We’ve analysed your solution and have 3 essential improvements, 1 recommendation and 2 additional comments" # rubocop:disable Layout/LineLength
        assert_text "Address the essential improvements before proceeding."
        assert_css ".status.passed"
      end
      assert_no_css "section.completion-nudge"
      assert_no_css "section.mentoring-nudge"
    end
  end
end
