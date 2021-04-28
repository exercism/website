require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module TrackMenu
      class ResetsTrackTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student resets track" do
          user = create :user
          track = create :track, title: "Ruby"
          create :concept_exercise, track: track
          create :user_track, user: user, track: track

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track menu"
            click_on "Reset track"
            within(".m-reset-track") { click_on "Reset track" }

            assert_text "Track has been reset"
          end
        end
      end
    end
  end
end
