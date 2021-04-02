require "application_system_test_case"

module Flows
  class StartExerciseTest < ApplicationSystemTestCase
    test "starts concept exercise succesfully" do
      track = create :track
      exercise = create :concept_exercise, track: track

      user = create :user
      create :user_track, user: user, track: track
      create :hello_world_solution, :completed, track: track, user: user

      sign_in!(user)

      visit track_exercise_url(track, exercise)

      within(".action-box") { click_on "Start" }

      assert_page "editor"

      assert Solution.for(user, exercise)
    end
  end
end
