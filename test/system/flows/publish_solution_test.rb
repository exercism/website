require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class PublishSolutionTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "user publishes solution when completing it" do
      track = create :track
      strings = create(:concept_exercise, track:)
      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, user:, exercise: strings
      submission = create(:submission, solution:)
      create(:iteration, idx: 2, submission:)
      submission = create(:submission, solution:)
      iteration_1 = create(:iteration, idx: 1, submission:)

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
        assert_text "You've published your exercise"

        # There is no way to determine from the screen which iteration was published. We can only check the solution record.
        solution.reload
        assert_equal iteration_1, solution.published_iteration
      end
    end

    test "user publishes a completed solution" do
      track = create :track
      strings = create(:concept_exercise, track:)
      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, :completed, user:, exercise: strings
      submission = create(:submission, solution:)
      create(:iteration, idx: 2, submission:)
      submission = create(:submission, solution:)
      iteration_1 = create(:iteration, idx: 1, submission:)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "Publish solution"
        find("label", text: "Single iteration").click
        click_on "Iteration 2"
        find("label", text: "Iteration 1").click
        click_on "Publish"

        wait_for_redirect
        assert_text "You've published your exercise"

        # There is no way to determine from the screen which iteration was published. We can only check the solution record.
        solution.reload
        assert_equal iteration_1, solution.published_iteration
      end
    end

    test "user sees their published solution" do
      track = create :track
      strings = create(:concept_exercise, track:)
      user = create :user, handle: "User"
      create(:user_track, user:, track:)
      solution = create :concept_solution, :completed, :published, user:, exercise: strings
      submission = create(:submission, solution:)
      iteration_2 = create(:iteration, idx: 2, submission:)
      solution.update!(published_iteration: iteration_2)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        assert_text "You've published your exercise"
        assert_link "User's solution", href: Exercism::Routes.published_solution_url(solution)
      end
    end

    test "user changes a published iteration" do
      track = create :track
      strings = create(:concept_exercise, track:)
      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, :completed, :published, user:, exercise: strings
      submission_1 = create(:submission, solution:)
      create :iteration, idx: 1, submission: submission_1
      create :submission_file, content: "module Bob\nend", filename: "bob.rb", submission: submission_1
      submission_2 = create(:submission, solution:)
      iteration_2 = create :iteration, idx: 2, submission: submission_2
      create :submission_file, content: "class Bob\nend", filename: "bob.rb", submission: submission_2
      submission_3 = create(:submission, solution:)
      create :iteration, :deleted, idx: 3, submission: submission_3
      create :submission_file, content: "just Bob\nend", filename: "bob.rb", submission: submission_3

      solution.update!(published_iteration: iteration_2)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        # Change published iteration to all iterations
        click_on "change published iteration"
        find("label", text: "All iterations").click
        click_on "Update published solution"
        assert_text "You've published your exercise"
        click_on(class: "c-community-solution")
        assert_text "class Bob"

        visit track_exercise_url(track, strings)

        # Change published iteration to specific iteration
        click_on "change published iteration"
        find("label", text: "Single iteration").click
        within(".c-single-select") do
          find("button").click
          assert_text "Iteration 1" # Show active iteration
          assert_text "Iteration 2" # Show active iteration
          refute_text "Iteration 3" # Don't show deleted iteration

          find(".row", text: "Iteration 1").find(:xpath, '../input', visible: false).click
        end

        click_on "Update published solution"
        click_on(class: "c-community-solution")
        assert_text "module Bob"
      end
    end

    test "user unpublishes an iteration" do
      track = create :track
      strings = create(:concept_exercise, track:)
      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, :completed, :published, user:, exercise: strings
      submission = create(:submission, solution:)
      iteration_2 = create(:iteration, idx: 2, submission:)
      submission = create(:submission, solution:)
      create(:iteration, idx: 1, submission:)
      solution.update!(published_iteration: iteration_2)

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_url(track, strings)

        click_on "unpublish your solution"
        click_on "Unpublish solution"

        assert_button "Publish solution"
      end
    end
  end
end
