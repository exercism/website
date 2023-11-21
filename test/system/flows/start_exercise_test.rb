require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StartExerciseTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "starts concept exercise succesfully" do
      track = create :track
      exercise = create(:concept_exercise, track:)

      user = create :user
      create(:user_track, user:, track:)
      create(:hello_world_solution, :completed, track:, user:)

      use_capybara_host do
        sign_in!(user)

        visit track_exercise_url(track, exercise)

        within(".action-box.pending") { click_on "Start in editor" }

        assert_page "editor"

        assert Solution.for(user, exercise)
      end
    end
  end
end
