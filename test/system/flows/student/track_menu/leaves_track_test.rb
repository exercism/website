require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"

module Flows
  module Student
    module TrackMenu
      class LeavesTrackTest < ApplicationSystemTestCase
        include CapybaraHelpers

        test "student leaves track" do
          user = create :user
          track = create :track, title: "Ruby"
          create :concept_exercise, track: track
          create :user_track, user: user, track: track

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track menu"
            click_on "Leave track"
            within(".m-leave-track") { click_on "Leave track" }

            assert_text "You have left the track"
          end
        end
      end
    end
  end
end
