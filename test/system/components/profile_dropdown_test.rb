require "application_system_test_case"

module Components
  class ProfileDropdownTest < ApplicationSystemTestCase
    test "clicking on dropdown button shows links" do
      sign_in!

      visit dashboard_path
      find(".user-menu").click

      assert_text "My Journey"
      assert_text "Profile"
      assert_text "Settings"
      assert_text "Sign out"
    end
  end
end
