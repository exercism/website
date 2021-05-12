require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class PublishExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user publishes solution when completing it" do
      track = create :track
      strings = create :concept_exercise, track: track
      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution
      iteration_2 = create :iteration, idx: 2, submission: submission
      submission = create :submission, solution: solution
      create :iteration, idx: 1, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "Mark as complete"
        find("label", text: "Yes, I'd like to share my solution with the community.").click
        choose "Single iteration"
        select "Iteration 2"
        click_on "Confirm"

        click_on "Continue"
        assert_text "Your published solution"

        # There is no way to determine from the screen which iteration was published. We can only check the solution record.
        solution.reload
        assert_equal iteration_2, solution.published_iteration
      end
    end

    test "user publishes a completed solution" do
      track = create :track
      strings = create :concept_exercise, track: track
      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, :completed, user: user, exercise: strings
      submission = create :submission, solution: solution
      iteration_2 = create :iteration, idx: 2, submission: submission
      submission = create :submission, solution: solution
      create :iteration, idx: 1, submission: submission

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "Publish solution"
        choose "Single iteration"
        select "Iteration 2"
        click_on "Submit"

        assert_text "Your published solution"
        # There is no way to determine from the screen which iteration was published. We can only check the solution record.
        solution.reload
        assert_equal iteration_2, solution.published_iteration
      end
    end
  end
end
