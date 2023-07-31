require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/websockets_helpers"

module Flows
  module Notifications
    class DrodpownTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include WebsocketsHelpers

      test "user views notifications" do
        user = create :user
        mentor = create :user, handle: "mr-mentor"
        discussion = create(:mentor_discussion, mentor:)
        create :mentor_started_discussion_notification, user:, params: { discussion: }, status: :unread
        create(:user_dismissed_introducer, slug: "welcome-modal", user:)

        use_capybara_host do
          sign_in!(user)
          visit dashboard_path
          within(".c-notification") { assert_text "1" }
          find(".c-notification").click

          assert_text "mr-mentor has started mentoring your solution to Bob in Ruby"
          assert_link "See all your notifications", href: notifications_url
        end
      end

      test "refetches on websocket notification" do
        user = create :user
        mentor = create :user, handle: "mrs-mentor"
        discussion = create(:mentor_discussion, mentor:)
        create(:user_dismissed_introducer, slug: "welcome-modal", user:)

        use_capybara_host do
          sign_in!(user)
          visit dashboard_path
          wait_for_websockets

          create :mentor_started_discussion_notification, user:, params: { discussion: }, status: :unread

          NotificationsChannel.broadcast_changed!(user)
          within(".c-notification") { assert_text "1" }
          find(".c-notification").click

          assert_text "mrs-mentor has started mentoring your solution to Bob in Ruby"
        end
      end

      test "only loads notifications when dropdown is closed" do
        user = create :user
        mentor = create :user, handle: "mrs-mentor"
        discussion = create(:mentor_discussion, mentor:)
        create(:user_dismissed_introducer, slug: "welcome-modal", user:)

        use_capybara_host do
          sign_in!(user)
          visit dashboard_path
          find(".c-notification").click

          create :mentor_started_discussion_notification, user:, params: { discussion: }, status: :unread
          NotificationsChannel.broadcast_changed!(user)
          wait_for_websockets

          assert_no_text "mrs-mentor has started mentoring your solution to Bob in Ruby"

          find(".c-notification").click
          find(".c-notification").click
          assert_text "mrs-mentor has started mentoring your solution to Bob in Ruby"
        end
      end
    end
  end
end
