require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentUpdatesSolutionTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student updates solution" do
      user = create :user
      track = create :track
      create :user_track, user: user, track: track
      exercise = create :concept_exercise, track: track, title: "Lasagna"
      create :concept_solution,
        git_sha: "ef19c86ee73dfbd3df8f3d49251008783a51de91",
        exercise: exercise,
        user: user

      use_capybara_host do
        sign_in!(user)
        visit track_exercise_path(track, exercise)
        click_on "This exercise has been updated"
        click_on "Update exercise"

        assert_no_text "This exercises has been updated"
      end
    end
  end
end
