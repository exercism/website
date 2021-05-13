require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class CompleteExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "completes succesfully" do
      track = create :track
      basics_concept = create :track_concept, track: track, name: "Basics"
      conditionals_concept = create :track_concept, track: track, name: "Conditionals"

      strings = create :concept_exercise, track: track
      strings.taught_concepts << basics_concept
      hello = create :practice_exercise, track: track, slug: "bob", title: "Bob"
      hello.prerequisites << basics_concept

      cars = create :concept_exercise, track: track, slug: "cars-assemble", title: "Cars Assemble"
      cars.prerequisites << basics_concept
      cars.taught_concepts << conditionals_concept

      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, strings)

        click_on "Mark as complete"
        click_on "Confirm"

        assert_text "You've completed\nStrings!"
        assert_text "You've unlocked\n2 exercises"
        assert_text "Bob"
        assert_text "Cars Assemble"
        assert_text "Basics"
        assert_text "Conditionals"

        click_on "Continue"
        assert_text "You've completed Strings."
      end
    end

    test "completes succesfully via nudge section" do
      track = create :track
      basics_concept = create :track_concept, track: track, name: "Basics"
      conditionals_concept = create :track_concept, track: track, name: "Conditionals"

      strings = create :concept_exercise, track: track
      strings.taught_concepts << basics_concept
      hello = create :practice_exercise, track: track, slug: "bob", title: "Bob"
      hello.prerequisites << basics_concept

      cars = create :concept_exercise, track: track, slug: "cars-assemble", title: "Cars Assemble"
      cars.prerequisites << basics_concept
      cars.taught_concepts << conditionals_concept

      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: strings
      submission = create :submission, solution: solution,
                                       tests_status: :passed,
                                       representation_status: :generated,
                                       analysis_status: :completed
      create :iteration, idx: 1, solution: solution, submission: submission

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, strings)

        within("section.completion-nudge") { click_on "Mark as complete" }
        click_on "Confirm"

        assert_text "You've completed\nStrings!"
        assert_text "You've unlocked\n2 exercises"
        assert_text "Bob"
        assert_text "Cars Assemble"
        assert_text "Basics"
        assert_text "Conditionals"

        click_on "Continue"

        assert_text "You've completed Strings."
        assert_no_css("section.completion-nudge")
      end
    end
  end
end
