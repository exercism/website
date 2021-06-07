require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentViewsCLIWalkthroughTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student views walkthrough" do
      use_capybara_host do
        sign_in!
        visit cli_walkthrough_url

        assert_text "Welcome to the Exercism installation guide!"
      end
    end

    test "student sees CLI configuration command" do
      user = create :user
      create :user_auth_token, token: "AUTH_TOKEN", user: user

      use_capybara_host do
        sign_in!(user)
        visit cli_walkthrough_url
        click_on "Mac"
        click_on "Yes"
        click_on "Yes"
        click_on "Configure the CLI"

        assert_text "exercism configure --token=AUTH_TOKEN"
      end
    end

    test "student views walkthrough in modal" do
      use_capybara_host do
        sign_in!
        visit modal_test_components_cli_walkthrough_url
        click_on "View walkthrough"

        assert_text "Welcome to the Exercism installation guide!"
      end
    end
  end
end
