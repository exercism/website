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

    test "user registers via Github" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
                                                                    provider: "github",
                                                                    uid: "111",
                                                                    info: {
                                                                      email: "user@exercism.io",
                                                                      name: "Name",
                                                                      nickname: "user22"
                                                                    }
                                                                  })
      visit new_user_registration_path
      click_on "Sign in with GitHub"

      refute_text "Please confirm your email"
      assert_text "Welcome to Exercism v3"

      OmniAuth.config.test_mode = false
    end
  end
end
