require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Components
  class ProfileDropdownTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "clicking on dropdown button shows links" do
      sign_in!

      use_capybara_host do
        visit dashboard_path
        find(".user-menu").click

        assert_text "Public Profile"
        assert_text "Your Journey"
        assert_text "Settings"
        assert_text "Sign out"
      end
    end
  end
end
