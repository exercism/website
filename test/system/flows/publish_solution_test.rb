require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class PublishSolutionTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "user publishes solution when completing it" do
      track = create :track
      strings = create :concept_exercise, track: track
      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution
      create :iteration, idx: 2, submission: submission
      submission = create :submission, solution: solution
      iteration_1 = create :iteration, idx: 1, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "Mark as complete"
        find("label", text: "Yes, I'd like to share my solution with the community.").click
        find("label", text: "Single iteration").click
        click_on "Iteration 2"
        find("label", text: "Iteration 1").click
        click_on "Confirm"

        assert_text "You've completed Strings!"
        within(".m-completed-exercise") { click_on "Return to the exercise" }
        wait_for_redirect
        assert_text "Your published solution"

        # There is no way to determine from the screen which iteration was published. We can only check the solution record.
        solution.reload
        assert_equal iteration_1, solution.published_iteration
      end
    end

    test "user publishes a completed solution" do
      track = create :track
      strings = create :concept_exercise, track: track
      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, :completed, user: user, exercise: strings
      submission = create :submission, solution: solution
      create :iteration, idx: 2, submission: submission
      submission = create :submission, solution: solution
      iteration_1 = create :iteration, idx: 1, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "Publish solution"
        find("label", text: "Single iteration").click
        click_on "Iteration 2"
        find("label", text: "Iteration 1").click
        click_on "Publish"

        wait_for_redirect
        assert_text "Your published solution"

        # There is no way to determine from the screen which iteration was published. We can only check the solution record.
        solution.reload
        assert_equal iteration_1, solution.published_iteration
      end
    end

    test "user sees their published solution" do
      track = create :track
      strings = create :concept_exercise, track: track
      user = create :user, handle: "User"
      create :user_track, user: user, track: track
      solution = create :concept_solution, :completed, :published, user: user, exercise: strings
      submission = create :submission, solution: solution
      iteration_2 = create :iteration, idx: 2, submission: submission
      solution.update!(published_iteration: iteration_2)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        assert_text "Your published solution"
        assert_link "User's solution", href: Exercism::Routes.published_solution_url(solution)
      end
    end

    test "user changes a published iteration" do
      track = create :track
      strings = create :concept_exercise, track: track
      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, :completed, :published, user: user, exercise: strings
      submission = create :submission, solution: solution
      iteration_2 = create :iteration, idx: 2, submission: submission
      submission = create :submission, solution: solution
      create :iteration, idx: 1, submission: submission
      solution.update!(published_iteration: iteration_2)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "Publish settings"
        click_on "Change published iteration"
        find("label", text: "All iterations").click
        click_on "Update published solution"

        assert_text "Your published solution"
        # There is no way to determine from the screen which iteration was published. We can only check the solution record.
        solution.reload
        assert_nil solution.published_iteration
      end
    end

    test "user unpublishes an iteration" do
      track = create :track
      strings = create :concept_exercise, track: track
      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, :completed, :published, user: user, exercise: strings
      submission = create :submission, solution: solution
      iteration_2 = create :iteration, idx: 2, submission: submission
      submission = create :submission, solution: solution
      create :iteration, idx: 1, submission: submission
      solution.update!(published_iteration: iteration_2)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "Publish settings"
        click_on "Unpublish"
        click_on "Unpublish solution"

        assert_button "Publish solution"
      end
    end
  end
end
