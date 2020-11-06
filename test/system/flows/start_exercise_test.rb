require "application_system_test_case"

module Flows
  class StartExerciseTest < ApplicationSystemTestCase
    test "starts concept exercise succesfully" do
      exercise = create :concept_exercise

      user = create :user
      create :user_track, user: user, track: exercise.track

      sign_in!(user)

      visit track_exercise_url(exercise.track, exercise)

      click_on "Start"

      assert_correct_page "editor"

      assert Solution.for(user, exercise)
    end
  end
end
