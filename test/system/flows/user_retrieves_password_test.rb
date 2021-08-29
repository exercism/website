require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserRetrievesPasswordTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user retrieves password" do
      create :user, email: "user@exercism.org"

      use_capybara_host do
        visit new_user_password_path
        fill_in "Email", with: "user@exercism.org"

        click_on "Send instructions"
      end

      assert_text "You will receive an email with instructions on how to reset your password in a few minutes."
    end

    test "user sees errors" do
      expecting_errors do
        create :user, email: "user@exercism.org"

        use_capybara_host do
          visit new_user_password_path
          fill_in "Email", with: " "

          click_on "Send instructions"
        end

        assert_text "Email can't be blank"
      end
    end
  end
end
