require "application_system_test_case"

module Components
  class NotificationsIconTest < ApplicationSystemTestCase
    test "shows no number for no notifications" do
      create(:user)

      visit test_components_notifications_icon_path
      wait_for_websockets
      fill_in "Count", with: 0
      click_on "Update"

      within "#test-area .c-notification" do
        refute_text "0"
      end
    end

    test "shows number for 1+ notifications" do
      create(:user)

      visit test_components_notifications_icon_path
      wait_for_websockets
      fill_in "Count", with: 1
      click_on "Update"

      within "#test-area .c-notification" do
        assert_text "1"
      end
    end

    test "shows number for <=99 notifications" do
      create(:user)

      visit test_components_notifications_icon_path
      wait_for_websockets
      fill_in "Count", with: 99
      click_on "Update"

      within "#test-area .c-notification" do
        assert_text "99"
      end
    end

    test "shows no number for >99 notifications" do
      create(:user)

      visit test_components_notifications_icon_path
      wait_for_websockets
      fill_in "Count", with: 100
      click_on "Update"

      within "#test-area .c-notification" do
        refute_text "100"
      end
    end
  end
end
