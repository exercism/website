require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class CompleteExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "completes succesfully" do
      track = create :track, slug: :fsharp
      basics_concept = create :track_concept, track: track, name: "Basics"
      conditionals_concept = create :track_concept, track: track, name: "Conditionals"

      lasagna = create :concept_exercise, slug: "lucians-luscious-lasagna", title: "Lasagna", track: track
      lasagna.taught_concepts << basics_concept
      hello = create :practice_exercise, track: track, slug: "hello-world", title: "Hello World"
      hello.prerequisites << basics_concept

      cars = create :concept_exercise, track: track, slug: "cars-assemble", title: "Cars Assemble"
      cars.prerequisites << basics_concept
      cars.taught_concepts << conditionals_concept

      user = create :user
      create :user_track, user: user, track: track
      solution = create :concept_solution, user: user, exercise: lasagna
      submission = create :submission, solution: solution
      create :iteration, submission: submission

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, lasagna)

        click_on "Mark as complete"
        find("label", text: "Yes, I'd like to share my solution with the community.").click
        click_on "Confirm"
      end

      assert_text "You've completed\nLasagna!"
      assert_text "You've unlocked\n2 exercises"
      assert_text "Hello World"
      assert_text "Cars Assemble"
      assert_text "Basics"
      assert_text "Conditionals"

      click_on "Continue"
      assert_text "You've completed Lasagna."
    end
  end
end
