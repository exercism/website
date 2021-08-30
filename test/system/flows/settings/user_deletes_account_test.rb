require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserDeletesAccountTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user deletes account" do
        user = create :user, handle: "handle"

        use_capybara_host do
          sign_in!(user)
          visit settings_path

          click_on "Delete account"
          fill_in "To confirm, write your handle handle in the box below:", with: "handle"
          within(".m-delete-account") { click_on "Delete account" }

          assert_page :landing
        end
      end
    end
  end
end
