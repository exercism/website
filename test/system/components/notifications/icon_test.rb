require "application_system_test_case"

module Components
  module Notifications
    class IconTest < ApplicationSystemTestCase
      test "shows the correct initial state" do
        create(:user)

        visit test_components_notifications_icon_path

        assert_text "Count\n0"
        assert_text "Unread\nfalse"
      end

      test "shows number of unread notifications" do
        create(:user)

        visit test_components_notifications_icon_path
        wait_for_websockets
        fill_in "Count", with: 2
        click_on "Update"

        assert_text "Count\n2"
        assert_text "Unread\ntrue"
      end
    end
  end
end
