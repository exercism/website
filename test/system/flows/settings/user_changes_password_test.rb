require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesPasswordTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user changes password" do
        user = create :user, password: "password"

        use_capybara_host do
          sign_in!(user)

          visit settings_path
          form = find("h2", text: "Change your password").ancestor("form")
          within(form) do
            fill_in "Current password", with: "password"
            fill_in "New password", with: "newpassword"
            fill_in "Confirm new password", with: "newpassword"
            click_on "Change password"
          end

          assert_button "Log In"
        end
      end

      test "user changes password with incorrect password" do
        user = create :user, password: "password"

        expecting_errors do
          use_capybara_host do
            sign_in!(user)

            visit settings_path
            form = find("h2", text: "Change your password").ancestor("form")
            within(form) do
              fill_in "Current password", with: "wrongpassword"
              fill_in "New password", with: "newpassword"
              fill_in "Confirm new password", with: "newpassword"
              click_on "Change password"
            end

            assert_text "Incorrect password"
          end
        end
      end

      test "user changes password when passwords dont match" do
        user = create :user, password: "password"

        expecting_errors do
          use_capybara_host do
            sign_in!(user)

            visit settings_path
            form = find("h2", text: "Change your password").ancestor("form")
            within(form) do
              fill_in "Current password", with: "password"
              fill_in "New password", with: "newpassword"
              fill_in "Confirm new password", with: "wrongpassword"
              click_on "Change password"
            end

            assert_text "Passwords don't match"
          end
        end
      end
    end
  end
end
