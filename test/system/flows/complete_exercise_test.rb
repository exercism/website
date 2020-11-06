require "application_system_test_case"

module Flows
  class CompleteExerciseTest < ApplicationSystemTestCase
    test "completes succesfully" do
      exercise = create :concept_exercise

      user = create :user
      create :user_track, user: user, track: exercise.track
      solution = create :concept_solution, user: user, exercise: exercise

      sign_in!(user)

      visit track_exercise_url(exercise.track, exercise)

      click_on "Mark as complete"

      assert_text "You’ve completed this exercise"

      assert solution.reload.completed?
    end
  end
end
