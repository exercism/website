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
          fill_in "Handle:", with: "handle"
          within(".m-delete-account") { click_on "Delete account" }

          assert_text "Account deleted"
        end
      end
    end
  end
end
