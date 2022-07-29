require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentUpdatesSolutionTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student updates solution" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise,
        track: track,
        slug: "lasagna",
        git_sha: "bc42eeda40b3d99a0379cd88a3bbbd0a12bce50a",
        git_important_files_hash: "cd65371ae91f57453b8a278998db1815afb41e7c"
      create :concept_solution,
        git_sha: "ac388147339875555f9df49d783d477492bebcf3",
        git_important_files_hash: "a75ab88416d5e437c0cef036ae557d653b41ca1b",
        exercise: exercise,
        user: user

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_path(track, exercise)
        click_on "This exercise has been updated"

        assert_text "lasagna_test.rb"
        assert_text "def test_total_time_in_minutes_for_multiple_layer"

        click_on "Update exercise"

        assert_no_text "This exercise has been updated"
      end
    end
  end
end
