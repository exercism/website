require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Components
  module Editor
    class TestsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user views tests" do
        user = create :user
        track = create :track
        exercise = create :practice_exercise, track: track
        create :user_track, track: track, user: user
        create :practice_solution, user: user, exercise: exercise

        use_capybara_host do
          sign_in!(user)
          visit edit_track_exercise_path(track, exercise)
          click_on "Tests"

          assert_text "test content"
        end
      end
    end
  end
end
