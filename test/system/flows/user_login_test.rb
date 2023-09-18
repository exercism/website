require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserLoginTest < ApplicationSystemTestCase
    include ShowMeTheCookies
    include CapybaraHelpers

    test "user logs in via Github and is remembered" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({ provider: "github", uid: "123",
                                                                    info: { nickname: "user22" } })
      create :user, :not_onboarded, uid: "123", provider: "github", confirmed_at: Date.new(2016, 12, 25)

      use_capybara_host do
        visit new_user_session_path
        click_on "Log In with GitHub"
        assert_page :onboarding

        expire_cookies
        visit new_user_session_path
        assert_page :onboarding
      end

      OmniAuth.config.test_mode = false
    end

    test "user logs in and is remembered" do
      create(:user,
        :not_onboarded,
        email: "user@exercism.org",
        password: "password",
        confirmed_at: Date.new(2016, 12, 25))

      use_capybara_host do
        visit new_user_session_path
        fill_in "Email", with: "user@exercism.org"
        fill_in "Password", with: "password"
        click_on "Log In"
        assert_page :onboarding

        expire_cookies
        visit new_user_session_path
        assert_page :onboarding
      end
    end

    test "user attempts to log in an account with a oauth password hash" do
      create(:user,
        email: "user@exercism.org",
        encrypted_password: "wrong",
        provider: "github",
        confirmed_at: Date.new(2016, 12, 25))

      use_capybara_host do
        visit new_user_session_path
        fill_in "Email", with: "user@exercism.org"
        fill_in "Password", with: "otherpassword"
        click_on "Log In"

        assert_text "Your account does not have a password. Please use OAuth."
      end
    end

    test "user logs in and is redirected to the correct page" do
      track = create :track, title: "Ruby"
      create(:concept_exercise, track:)
      create(:user,
        email: "user@exercism.org",
        password: "password",
        confirmed_at: Date.new(2016, 12, 25))

      use_capybara_host do
        visit track_path(track)
        click_on "Join the Ruby Track"
        fill_in "Email", with: "user@exercism.org"
        fill_in "Password", with: "password"
        click_on "Log In"

        assert_text "Join the Ruby Track", wait: 10
      end
    end

    test "user sees errors" do
      expecting_errors do
        track = create :track, title: "Ruby"
        create(:concept_exercise, track:)
        create(:user,
          email: "user@exercism.org",
          password: "password",
          confirmed_at: Date.new(2016, 12, 25))

        use_capybara_host do
          visit new_user_session_path
          fill_in "Email", with: "user@exercism.org"
          click_on "Log In"

          assert_text "Invalid Email or password."
        end
      end
    end

    test "user logs in, onboards, and is redirected to the correct page" do
      track = create :track, title: "Ruby"
      create(:concept_exercise, track:)
      create(:user,
        :not_onboarded,
        email: "user@exercism.org",
        password: "password",
        confirmed_at: Date.new(2016, 12, 25))

      use_capybara_host do
        visit track_path(track)
        click_on "Join the Ruby Track"
        fill_in "Email", with: "user@exercism.org"
        fill_in "Password", with: "password"
        click_on "Log In"
        find('label', text: "I accept Exercism's Terms of Service").click
        find('label', text: "I accept Exercism's Privacy Policy").click
        click_on "Save & Get Started"

        assert_text "Join the Ruby Track", wait: 10
      end
    end
  end
end
