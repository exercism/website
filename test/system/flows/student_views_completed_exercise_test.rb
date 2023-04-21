require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentViewsCompletedExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student views unlocked concept info" do
      track = create :track
      basics_concept = create :concept, track:, name: "Basics"
      conditionals_concept = create :concept,
        track:,
        name: "Conditionals",
        blurb: "This is conditionals"

      strings = create(:concept_exercise, track:)
      strings.taught_concepts << basics_concept
      hello = create :practice_exercise, track:, slug: "bob", title: "Bob"
      hello.prerequisites << basics_concept

      cars = create :concept_exercise, track:, slug: "cars-assemble", title: "Cars Assemble"
      cars.prerequisites << basics_concept
      cars.taught_concepts << conditionals_concept

      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, user:, exercise: strings, completed_at: 1.day.ago
      submission = create(:submission, solution:)
      create(:iteration, submission:)

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, strings)
        find_link("Conditionals").hover

        assert_text "This is conditionals"
      end
    end

    test "student views unlocked exercise info" do
      track = create :track
      basics_concept = create :concept, track:, name: "Basics"
      conditionals_concept = create :concept, track:, name: "Conditionals"

      strings = create(:concept_exercise, track:)
      strings.taught_concepts << basics_concept
      bob = create :practice_exercise, track:, slug: "bob", title: "Bob", blurb: "This is bob"
      bob.prerequisites << basics_concept

      cars = create :concept_exercise, track:, slug: "cars-assemble", title: "Cars Assemble"
      cars.prerequisites << basics_concept
      cars.taught_concepts << conditionals_concept

      user = create :user
      create(:user_track, user:, track:)
      solution = create :concept_solution, user:, exercise: strings, completed_at: 1.day.ago
      submission = create(:submission, solution:)
      create(:iteration, submission:)

      sign_in!(user)

      use_capybara_host do
        visit track_exercise_url(track, strings)
        find_link("Bob").hover

        assert_text "This is bob"
      end
    end
  end
end
