require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class UserCreatesAProfileTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "user creates a profile" do
      user = create :user, reputation: 0

      use_capybara_host do
        sign_in!(user)
        visit intro_profiles_path

        assert_text "Get 5 reputation to unlock profile creation."

        user.update!(reputation: 5)

        # Refresh the page
        visit intro_profiles_path

        click_on "Create a public profile"
        click_on "Create profile"

        wait_for_redirect
        assert_text "You now have a public profile"
      end
    end
  end
end
