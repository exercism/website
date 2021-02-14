require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/websockets_helpers"

module Flows
  class UserLoadsNotificationsTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include WebsocketsHelpers

    test "user views notifications" do
      user = create :user
      badge = create :rookie_badge
      create :acquired_badge_notification, user: user, params: { badge: badge }

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        within(".c-notification") { assert_text "1" }
        find(".c-notification").click

        assert_text "You have been awarded the Rookie badge."
        assert_link "View more notifications", href: notifications_url
      end
    end

    test "refetches on websocket notification" do
      user = create :user
      badge = create :rookie_badge

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        wait_for_websockets
        create :acquired_badge_notification, user: user, params: { badge: badge }
        NotificationsChannel.broadcast_changed(user)
        within(".c-notification") { assert_text "1" }
        find(".c-notification").click

        assert_text "You have been awarded the Rookie badge."
      end
    end

    test "user views unrevealed badges" do
      user = create :user
      badge = create :rookie_badge
      create :user_acquired_badge, user: user, badge: badge, revealed: false

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        find(".c-notification").click

        assert_link "You've earned a new badge", href: badges_journey_url
      end
    end
  end
end
