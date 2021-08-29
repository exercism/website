require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserRequestsConfirmationTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user requests confirmation" do
      stub_request(:get, "https://raw.githubusercontent.com/exercism/v3-beta/main/README.md?q=#{Time.current.min}").
        to_return(status: 200, body: "# Hello world", headers: {})
      create :user, email: "user@exercism.org"

      use_capybara_host do
        visit new_user_confirmation_path
        fill_in "Email", with: "user@exercism.org"

        click_on "Resend confirmation instructions"
      end

      assert_text "You will receive an email with instructions for how to confirm your email address in a few minutes."
    end

    test "user sees confirmation errors" do
      expecting_errors do
        create :user, email: "user@exercism.org"

        use_capybara_host do
          visit new_user_confirmation_path

          click_on "Resend confirmation instructions"
        end

        assert_text "Email can't be blank"
      end
    end
  end
end
