require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserUpdatesProfileTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user updates profile" do
        user = create :user

        use_capybara_host do
          sign_in!(user)

          visit settings_path
          fill_in "Name", with: "Name"
          click_on "Save profile data"

          assert_field "Name", with: "Name"
          assert_text "Your profile has been saved"
        end
      end

      test "user sees errors" do
        user = create :user

        expecting_errors do
          use_capybara_host do
            sign_in!(user)

            visit settings_path
            fill_in "Name", with: ""
            click_on "Save profile data"

            assert_text "Unable to save the resource"
          end
        end
      end
    end
  end
end
