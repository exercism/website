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
          create(:user_dismissed_introducer, slug: "track-welcome-modal-#{track.slug}", user:)
          create(:concept_exercise, track:)
          create(:user_track, user:, track:)

          stub_latest_track_forum_threads(track)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track options"
            click_on "Disable Learning Mode"
            within(".m-activate-practice-mode") { click_on "Disable Learning Mode" }

            assert_text "Practice Mode"
          end
        end
      end
    end
  end
end
