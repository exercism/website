require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"
require_relative "../../../../support/redirect_helpers"

module Flows
  module Student
    module TrackMenu
      class ResetsTrackTest < ApplicationSystemTestCase
        include CapybaraHelpers
        include RedirectHelpers

        test "student resets track" do
          create :user, :ghost
          user = create :user
          track = create :track, title: "Ruby"
          create(:user_dismissed_introducer, slug: "track-welcome-modal-#{track.slug}", user:)
          create(:concept_exercise, track:)
          create :concept_solution, status: :completed, user:, completed_at: 2.days.ago
          create(:user_track, user:, track:)

          stub_latest_track_forum_threads(track)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track options"
            click_on "Reset track"
            fill_in "To confirm", with: "reset ruby"
            within(".m-reset-track") { click_on "Reset track" }

            wait_for_redirect
            assert_text "You've just started the Ruby track"
          end
        end
      end
    end
  end
end
