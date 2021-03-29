require "application_system_test_case"

module Flows
  class StartExerciseTest < ApplicationSystemTestCase
    test "starts concept exercise succesfully" do
      track = create :track
      exercise = create :concept_exercise, track: track

      user = create :user
      create :user_track, user: user, track: track

      sign_in!(user)

      visit track_exercise_url(track, exercise)

      within(".action-box") { click_on "Start" }

      assert_page "editor"

      assert Solution.for(user, exercise)
    end

    test "starts concept exercise from open editor button" do
      track = create :track
      exercise = create :concept_exercise, track: track

      user = create :user
      create :user_track, user: user, track: track

      sign_in!(user)

      visit track_exercise_url(track, exercise)
      within(".navbar") { click_on "Start in editor" }

      assert_page "editor"
      assert Solution.for(user, exercise)
    end

    test "shows download command" do
      track = create :track
      exercise = create :concept_exercise, track: track

      user = create :user
      create :user_track, user: user, track: track

      sign_in!(user)
      visit track_exercise_url(track, exercise)
      within(".navbar") { find(".--dropdown-segment").click }

      assert_text "exercism download"
    end
  end
end
