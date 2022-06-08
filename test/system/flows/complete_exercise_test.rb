require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class CompleteExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "completes succesfully" do
      track = create :track
      basics = create :concept, track: track, name: "Basics"
      conditionals = create :concept, track: track, name: "Conditionals"
      strings = create :concept, track: track, name: "Strings"

      boutique = create :concept_exercise, track: track, slug: 'boutique', title: "Boutique"
      boutique.taught_concepts << basics

      bob = create :practice_exercise, track: track, slug: "bob", title: "Bob"
      bob.prerequisites << basics

      cars = create :concept_exercise, track: track, slug: "cars-assemble", title: "Cars Assemble"
      cars.prerequisites << basics
      cars.taught_concepts << conditionals

      leap = create :practice_exercise, track: track, slug: "leap", title: "Leap"
      leap.prerequisites << basics
      leap.prerequisites << conditionals

      misc = create(:concept_exercise, track:)
      misc.taught_concepts << strings
      misc.prerequisites << conditionals

      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: boutique
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, boutique)

        click_on "Mark as complete"
        click_on "Confirm"

        assert_text "You've completed Boutique!"
        assert_text "1 concept"
        assert_text "2 exercises"
        assert_text "Bob"
        assert_text "Cars Assemble"
        refute_text "Leap"
        assert_text "Basics"
        assert_text "Conditionals"
        refute_text "Strings"

        within(".m-completed-exercise") { click_on "Return to the exercise" }

        wait_for_redirect
        assert_text "You've completed Boutique."

        within '.unlocked-exercises' do
          assert_text "Bob"
          assert_text "Cars Assemble"
          refute_text "Leap"
        end

        within '.unlocked-concepts' do
          assert_text "Conditionals"
          refute_text "Strings"
        end
      end
    end

    test "completes succesfully via nudge section" do
      track = create :track
      basics = create :concept, track: track, name: "Basics"

      boutique = create :concept_exercise, track: track, slug: 'boutique', title: "Boutique"
      boutique.taught_concepts << basics

      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: boutique
      submission = create :submission, solution: solution,
        tests_status: :passed,
        representation_status: :generated,
        analysis_status: :completed
      create :iteration, idx: 1, solution: solution, submission: submission

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, boutique)

        within("section.completion-nudge") { click_on "Mark as complete" }
        click_on "Confirm"

        assert_text "You've completed Boutique!"

        within(".m-completed-exercise") { click_on "Return to the exercise" }

        wait_for_redirect
        assert_text "You've completed Boutique."
        assert_no_css("section.completion-nudge")
      end
    end
  end
end
