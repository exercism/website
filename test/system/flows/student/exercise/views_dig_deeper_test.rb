require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module Exercise
      class ViewsDigDeeperTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "view dig deeper section by unlocking via unlock button" do
          user = create :user
          track = create :track
          create :user_track, user: user, track: track
          create :hello_world_solution, :completed, track: track, user: user
          exercise = create :practice_exercise, track: track, slug: 'hamming'
          create :exercise_approach, exercise: exercise
          create :exercise_article, exercise: exercise
          exercise.update(has_approaches: true)

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_path(track, exercise)

            assert_text "Dig Deeper"
            find("span", text: "Dig Deeper").ancestor("div[data-tooltip-type=\"automation-locked\"]").hover
            assert_text "You can only view the Dig Deeper tab for this exercise if you've attempted this exercise at least once."

            # Simulate having passing tests
            solution = create :practice_solution, user: user, exercise: exercise, downloaded_at: Time.current

            visit track_exercise_path(track, exercise)

            find("span", text: "Dig Deeper").ancestor("div[data-tooltip-type=\"automation-locked\"]").hover
            refute_text "You can only view the Dig Deeper tab for this exercise if you've attempted this exercise at least once."

            # Simulate clicking on the unlock help button, which unfortunately doesn't
            # seem to render in a headless browser
            solution.update(unlocked_help: true)

            visit track_exercise_path(track, exercise)
            click_on "Dig Deeper"

            assert_text "Performance" # Shows article
            assert_text "Readability" # Shows approach
          end
        end

        test "view dig deeper section by iterating" do
          user = create :user
          track = create :track
          create :user_track, user: user, track: track
          create :hello_world_solution, :completed, track: track, user: user
          exercise = create :practice_exercise, track: track, slug: 'hamming'
          create :exercise_approach, exercise: exercise
          create :exercise_article, exercise: exercise
          exercise.update(has_approaches: true)

          use_capybara_host do
            sign_in!(user)
            visit track_exercise_path(track, exercise)

            assert_text "Dig Deeper"
            find("span", text: "Dig Deeper").ancestor("div[data-tooltip-type=\"automation-locked\"]").hover
            assert_text "You can only view the Dig Deeper tab for this exercise if you've attempted this exercise at least once."

            # Simulate having submitted an iteration
            solution = create :practice_solution, user: user, exercise: exercise
            submission = create :submission, solution: solution
            create :iteration, submission: submission

            visit track_exercise_path(track, exercise)

            click_on "Dig Deeper"

            assert_text "Performance" # Shows article
            assert_text "Readability" # Shows approach
          end
        end
      end
    end
  end
end
