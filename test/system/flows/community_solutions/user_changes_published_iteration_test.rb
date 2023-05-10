require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module CommunitySolutions
    class PublishSolutionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "views own community solution and changes published iteration" do
        track = create :track
        exercise = create(:concept_exercise, track:)
        author = create :user, handle: "author"
        create(:user_track, user: author, track:)
        solution = create(:concept_solution, :completed, :published, user: author, exercise:)
        submission_1 = create(:submission, solution:)
        iteration_1 = create :iteration, idx: 1, submission: submission_1
        create :submission_file, content: "module Bob\nend", filename: "bob.rb", submission: submission_1
        submission_2 = create(:submission, solution:)
        create :iteration, idx: 2, submission: submission_2
        create :submission_file, content: "class Bob\nend", filename: "bob.rb", submission: submission_2
        submission_3 = create(:submission, solution:)
        create :iteration, :deleted, idx: 3, submission: submission_3
        create :submission_file, content: "just Bob\nend", filename: "bob.rb", submission: submission_3

        solution.update!(published_iteration: iteration_1)

        use_capybara_host do
          sign_in!(author)
          visit track_exercise_solution_url(track, exercise, "author")

          # Change published iteration to all iterations
          click_on "Publish settings"
          click_on "Change published iterations…"
          find("label", text: "All iterations").click
          click_on "Update published solution"

          assert_text "Your solution"
          assert_text "class Bob"
          assert_button("1", class: "iteration")
          assert_button("2", class: "iteration", disabled: true)
          refute_button("3", class: "iteration")

          visit track_exercise_solution_url(track, exercise, "author")

          # Change published iteration to specific iteration
          click_on "Publish settings"
          click_on "Change published iteration"
          find("label", text: "Single iteration").click
          within(".c-single-select") do
            find("button").click
            assert_text "Iteration 1" # Show active iteration
            assert_text "Iteration 2" # Show active iteration
            refute_text "Iteration 3" # Don't show deleted iteration

            find(".row", text: "Iteration 1").find(:xpath, '../input', visible: false).click
            find("button").click
          end

          click_on "Update published solution"
          assert_text "Your solution"
          assert_text "module Bob"

          # Single published iterations don't have iteration buttons
          refute_button("1", class: "iteration")
          refute_button("2", class: "iteration")
          refute_button("3", class: "iteration")
        end
      end

      test "views other community solution with single published iteration" do
        user = create :user
        track = create :track
        exercise = create(:concept_exercise, track:)
        author = create :user, handle: "author"
        create(:user_track, user: author, track:)
        solution = create(:concept_solution, :completed, :published, user: author, exercise:)
        submission_1 = create(:submission, solution:)
        iteration_1 = create :iteration, idx: 1, submission: submission_1
        create :submission_file, content: "module Bob\nend", filename: "bob.rb", submission: submission_1
        submission_2 = create(:submission, solution:)
        create :iteration, idx: 2, submission: submission_2
        create :submission_file, content: "class Bob\nend", filename: "bob.rb", submission: submission_2
        submission_3 = create(:submission, solution:)
        create :iteration, :deleted, idx: 3, submission: submission_3
        create :submission_file, content: "just Bob\nend", filename: "bob.rb", submission: submission_3

        solution.update!(published_iteration: iteration_1)

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_solution_url(track, exercise, "author")

          assert_text "author's solution"
          assert_text "module Bob"

          # Single published iterations don't have iteration buttons
          refute_button("1", class: "iteration")
          refute_button("2", class: "iteration")
          refute_button("3", class: "iteration")
        end
      end

      test "views other community solution with all iterations published" do
        user = create :user
        track = create :track
        exercise = create(:concept_exercise, track:)
        author = create :user, handle: "author"
        create(:user_track, user: author, track:)
        solution = create(:concept_solution, :completed, :published, user: author, exercise:)
        submission_1 = create(:submission, solution:)
        create :iteration, idx: 1, submission: submission_1
        create :submission_file, content: "module Bob\nend", filename: "bob.rb", submission: submission_1
        submission_2 = create(:submission, solution:)
        create :iteration, idx: 2, submission: submission_2
        create :submission_file, content: "class Bob\nend", filename: "bob.rb", submission: submission_2
        submission_3 = create(:submission, solution:)
        create :iteration, :deleted, idx: 3, submission: submission_3
        create :submission_file, content: "just Bob\nend", filename: "bob.rb", submission: submission_3

        use_capybara_host do
          sign_in!(user)
          visit track_exercise_solution_url(track, exercise, "author")

          assert_text "author's solution"
          assert_text "class Bob"
          assert_button("1", class: "iteration")
          assert_button("2", class: "iteration", disabled: true)
          refute_button("3", class: "iteration")

          click_on("1", class: "iteration")
          assert_text "module Bob"
          assert_button("1", class: "iteration", disabled: true)
          assert_button("2", class: "iteration")
          refute_button("3", class: "iteration")
        end
      end
    end
  end
end
