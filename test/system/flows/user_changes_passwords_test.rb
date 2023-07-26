require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserChangesPasswordTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user changes password" do
      user = create :user
      token  = user.send_reset_password_instructions

      use_capybara_host do
        visit edit_user_password_path(reset_password_token: token)
        fill_in "New password", with: "password"
        fill_in "Confirm new password", with: "password"

        click_on "Change my password"
      end

      assert_text "Your password has been changed successfully."
    end

    test "user sees errors" do
      expecting_errors do
        user = create :user
        token  = user.send_reset_password_instructions

        use_capybara_host do
          visit edit_user_password_path(reset_password_token: token)
          fill_in "New password", with: "password"

          click_on "Change my password"
        end

        assert_text "Password confirmation doesn't match Password"
      end
    end
  end
end
