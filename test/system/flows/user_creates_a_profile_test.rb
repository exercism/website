require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserCreatesAProfileTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user creates a profile" do
      user = create :user

      use_capybara_host do
        sign_in!(user)
        visit new_profile_path

        click_on "Create profile"

        assert_text "Creating profile..."
        assert_no_text "Creating profile..."
        assert_text "You now have a public profile"
      end
    end
  end
end
