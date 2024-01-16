require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class CompleteExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "completes succesfully" do
      track = create :track
      basics = create :concept, track:, name: "Basics"
      conditionals = create :concept, track:, name: "Conditionals"
      strings = create :concept, track:, name: "Strings"

      boutique = create :concept_exercise, track:, slug: 'boutique', title: "Boutique"
      boutique.taught_concepts << basics

      bob = create :practice_exercise, track:, slug: "bob", title: "Bob"
      bob.prerequisites << basics

      cars = create :concept_exercise, track:, slug: "cars-assemble", title: "Cars Assemble"
      cars.prerequisites << basics
      cars.taught_concepts << conditionals

      leap = create :practice_exercise, track:, slug: "leap", title: "Leap"
      leap.prerequisites << basics
      leap.prerequisites << conditionals

      misc = create(:concept_exercise, track:)
      misc.taught_concepts << strings
      misc.prerequisites << conditionals

      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, user:, exercise: boutique
      submission = create(:submission, solution:)
      create(:iteration, submission:)

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

        within '.completed-info' do
          assert_text "Bob"
          assert_text "Cars Assemble"
          refute_text "Leap"
          assert_text "Conditionals"
          refute_text "Strings"
        end
      end
    end

    test "completes succesfully via nudge section" do
      track = create :track
      basics = create :concept, track:, name: "Basics"

      boutique = create :concept_exercise, track:, slug: 'boutique', title: "Boutique"
      boutique.taught_concepts << basics

      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, user:, exercise: boutique
      submission = create :submission, solution:,
        tests_status: :passed,
        representation_status: :generated,
        analysis_status: :completed
      create(:iteration, idx: 1, solution:, submission:)

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, boutique)

        click_on "Mark as complete"
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
