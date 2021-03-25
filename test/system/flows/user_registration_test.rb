require "application_system_test_case"

module Flows
  class UserRegistrationTest < ApplicationSystemTestCase
    setup do
      @__skip_stubbing_rest_client__ = true
    end

    test "user registers successfully" do
      allow_captcha_request do
        visit new_user_registration_path
        fill_in "Email", with: "user@exercism.io"
        fill_in "Username", with: "user22"
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
        click_on "Sign Up"

        assert_text "Check your email"
      end
    end

    test "user sees captcha errors" do
      allow_captcha_request do
        stub_request(:post, "https://hcaptcha.com/siteverify").
          to_return(body: { success: false }.to_json)

        visit new_user_registration_path
        fill_in "Email", with: "user@exercism.io"
        fill_in "Username", with: "user22!"
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
        click_on "Sign Up"

        assert_text "Captcha verification failed. Please try again."
      end
    end

    test "user sees registration errors" do
      allow_captcha_request do
        visit new_user_registration_path
        fill_in "Email", with: "user@exercism.io"
        fill_in "Username", with: "user22!"
        fill_in "Password", with: "password"
        fill_in "Password confirmation", with: "password"
        click_on "Sign Up"

        assert_text "Handle must have only letters, numbers, or hyphens"
      end
    end

    test "user registers via Github" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "111",
        info: {
          email: "user@exercism.io",
          name: "Name",
          nickname: "user22"
        }
      )
      visit new_user_registration_path
      click_on "Sign Up with GitHub"

      refute_text "Check your email"
      assert_page :onboarding

    ensure
      OmniAuth.config.test_mode = false
    end

    test "user registers via Github, onboards, and is redirected to the correct page" do
      track = create :track, title: "Ruby"
      create :concept_exercise, track: track

      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "111",
        info: {
          email: "user@exercism.io",
          name: "Name",
          nickname: "user22"
        }
      )
      visit track_path(track)
      click_on "Join the Ruby Track"
      visit new_user_registration_path
      click_on "Sign Up with GitHub"
      find('label', text: "I accept Exercism's Terms of Service").click
      find('label', text: "I accept Exercism's Privacy Policy").click
      click_on "Save & Get Started"

      sleep(0.2)
      assert_text "Join the Ruby Track"
    ensure
      OmniAuth.config.test_mode = false
    end

    test "user sees errors when registering via Github" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "111",
        info: {
          email: nil,
          name: "Name",
          nickname: "user22"
        }
      )
      visit new_user_registration_path
      click_on "Sign Up with GitHub"

      assert_text "Sorry, we could not authenticate you from GitHub."

    ensure
      OmniAuth.config.test_mode = false
    end

    test "user sees errors when initial OAuth exchange fails" do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = :failed

      # Check the outputter outputs an error and also
      # stop putting noise in the test logs.
      OmniAuth.config.logger.expects(:error).with("(github) Authentication failure! failed encountered.")

      visit new_user_registration_path
      click_on "Sign Up with GitHub"

      assert_text "Sorry, we could not authenticate you from GitHub."
    ensure
      OmniAuth.config.test_mode = false
    end

    private
    def allow_captcha_request
      stub_request(:post, "https://hcaptcha.com/siteverify").
        to_return(body: { success: true }.to_json)

      yield
    end
  end
end
