require "application_system_test_case"

module Flows
  class UserLoginTest < ApplicationSystemTestCase
    include ShowMeTheCookies

    test "user logs in via Github and is remembered" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({ provider: "github", uid: "123" })
      create :user, :not_onboarded, uid: "123", provider: "github", confirmed_at: Date.new(2016, 12, 25)

      visit new_user_session_path
      click_on "Log In with GitHub"
      assert_text "Onboarding"
      expire_cookies
      visit new_user_session_path
      assert_text "Onboarding"

      OmniAuth.config.test_mode = false
    end

    test "user attempts to log in an account with a oauth password hash" do
      create(:user,
        email: "user@exercism.io",
        encrypted_password: "wrong",
        provider: "github",
        confirmed_at: Date.new(2016, 12, 25))

      visit new_user_session_path
      fill_in "Email", with: "user@exercism.io"
      fill_in "Password", with: "otherpassword"
      click_on "Log In"

      assert_text "Your account does not have a password. Please use OAuth."
    end

    test "user logs in and is redirected to the correct page" do
      track = create :track, title: "Ruby"
      create(:user,
        email: "user@exercism.io",
        password: "password",
        confirmed_at: Date.new(2016, 12, 25))

      visit track_path(track)
      click_on "Join The Ruby Track"
      fill_in "Email", with: "user@exercism.io"
      fill_in "Password", with: "password"
      click_on "Log In"

      assert_text "Join The Ruby Track"
    end

    test "user logs in, onboards, and is redirected to the correct page" do
      track = create :track, title: "Ruby"
      create(:user,
        :not_onboarded,
        email: "user@exercism.io",
        password: "password",
        confirmed_at: Date.new(2016, 12, 25))

      visit track_path(track)
      click_on "Join The Ruby Track"
      fill_in "Email", with: "user@exercism.io"
      fill_in "Password", with: "password"
      click_on "Log In"
      check "Accept Terms of Service"
      check "Accept Privacy Policy"
      click_on "Submit"

      assert_text "Join The Ruby Track"
    end
  end
end
