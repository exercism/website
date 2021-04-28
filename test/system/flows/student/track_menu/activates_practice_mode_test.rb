require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module TrackMenu
      class ActivatesPracticeModeTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student activates practice mode" do
          user = create :user
          track = create :track, title: "Ruby"
          create :concept_exercise, track: track
          create :user_track, user: user, track: track

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track menu"
            click_on "Activate practice mode"
            within(".m-activate-practice-mode") { click_on "Activate practice mode" }

            assert_text "In practice mode"
          end
        end
      end
    end
  end
end
