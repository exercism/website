require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Components
  class ProfileDropdownTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "clicking on dropdown button shows links" do
      user = create :user
      create(:user_dismissed_introducer, slug: "welcome-modal", user:)

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        find(".user-menu").click

        assert_text "Public Profile"
        assert_text "Your Journey"
        assert_text "Settings"
        assert_text "Sign out"

        # Things that normal users shouldn't see
        refute_text "Maintaining"
      end
    end

    test "specific-user links show" do
      user = create :user, :maintainer
      create(:user_dismissed_introducer, slug: "welcome-modal", user:)

      use_capybara_host do
        sign_in!(user)
        visit dashboard_path
        find(".user-menu").click

        assert_text "Maintaining"
      end
    end
  end
end
