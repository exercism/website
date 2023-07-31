require "application_system_test_case"
require_relative "../../../../support/capybara_helpers"
require_relative "../../../../support/redirect_helpers"

module Flows
  module Student
    module TrackMenu
      class LeavesTrackTest < ApplicationSystemTestCase
        include CapybaraHelpers
        include RedirectHelpers

        test "student leaves track" do
          skip

          create :user, :ghost
          user = create :user
          track = create :track, title: "Ruby"
          create(:concept_exercise, track:)
          create :concept_solution, status: :completed, user:, completed_at: 2.days.ago
          create(:user_track, user:, track:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track options"
            click_on "Leave track"
            within(".m-leave-track") { click_on "Leave track" }

            click_on "Ruby"
            click_on "Join the Ruby track"

            wait_for_redirect
            assert_text "You’re 100% through the Ruby track."
          end
        end

        test "student leaves and resets track" do
          skip

          create :user, :ghost
          user = create :user
          track = create :track, title: "Ruby"
          create(:concept_exercise, track:)
          create :concept_solution, status: :completed, user:, completed_at: 2.days.ago
          create(:user_track, user:, track:)

          use_capybara_host do
            sign_in!(user)
            visit track_url(track)
            click_on "Track options"
            click_on "Leave track"
            click_on "Leave + Reset"
            fill_in "To confirm", with: "reset ruby"
            within("form") { click_on "Leave + Reset" }

            click_on "Ruby"
            click_on "Join the Ruby track"

            wait_for_redirect
            assert_text "You’ve just started the Ruby track"
          end
        end
      end
    end
  end
end
