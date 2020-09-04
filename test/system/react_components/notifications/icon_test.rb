require "application_system_test_case"

module Notifications
  class IconTest < ApplicationSystemTestCase
    test "increments number when a notification is created" do
      create(:user)

      visit test_components_notifications_icon_path
      click_on "Create notification"

      assert_text "Count\n1", wait: 1
    end

    test "shows unread state when a new notification is created" do
      create(:user)

      visit test_components_notifications_icon_path
      click_on "Create notification"

      assert_text "Unread\ntrue", wait: 1
    end
  end
end
