require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class StudentViewsWalkthroughTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "student views walkthrough" do
      use_capybara_host do
        sign_in!
        visit temp_walkthrough_url

        assert_text "Welcome to the Exercism installation guide!"
      end
    end

    test "student sees CLI configuration command" do
      user = create :user
      create :user_auth_token, token: "AUTH_TOKEN", user: user

      use_capybara_host do
        sign_in!(user)
        visit temp_walkthrough_url
        click_on "Mac"
        click_on "Yes"
        click_on "Yes"
        click_on "Configure the CLI"

        assert_text "exercism configure --token=AUTH_TOKEN"
      end
    end
  end
end
