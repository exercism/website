require "application_system_test_case"

module Flows
  class UserRegistrationTest < ApplicationSystemTestCase
    test "user registers successfully" do
      visit new_user_registration_path
      fill_in "Name", with: "Name"
      fill_in "Email", with: "user@exercism.io"
      fill_in "Handle", with: "user22"
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"
      click_on "Sign up"

      assert_text "Please confirm your email"
    end
  end
end
