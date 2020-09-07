require "application_system_test_case"

module Components
  module Notifications
    class IconTest < ApplicationSystemTestCase
      test "increments number when a notification is created" do
        create(:user)

        visit test_components_notifications_icon_path
        wait_for_websockets
        click_on "Create notification"

        assert_text "Count\n1"
      end

      test "shows unread state when a new notification is created" do
        create(:user)

        visit test_components_notifications_icon_path
        wait_for_websockets
        click_on "Create notification"

        assert_text "Unread\ntrue"
      end
    end
  end
end
