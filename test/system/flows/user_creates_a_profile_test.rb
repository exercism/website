require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/redirect_helpers"

module Flows
  class UserCreatesAProfileTest < ApplicationSystemTestCase
    include CapybaraHelpers
    include RedirectHelpers

    test "user creates a profile" do
      user = create :user

      use_capybara_host do
        sign_in!(user)
        visit new_profile_path

        click_on "Create profile"

        wait_for_redirect
        assert_text "You now have a public profile"
      end
    end
  end
end
