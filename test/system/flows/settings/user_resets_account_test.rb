require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserResetsAccountTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user resets account" do
        user = create :user, handle: "handle"

        use_capybara_host do
          sign_in!(user)
          visit settings_path

          click_on "Reset account"
          fill_in "To confirm, write your handle handle in the box below:", with: "handle"
          within(".m-reset-account") { click_on "Reset account" }

          assert_page :dashboard
        end
      end
    end
  end
end
