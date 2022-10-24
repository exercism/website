require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserSeesWelcomeModalTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user sees welcome modal" do
      skip # We've deprecated this for now
      use_capybara_host do
        sign_in!
        visit dashboard_path

        assert_text "Welcome to Exercism V3!"
      end
    end

    test "user dismisses modal" do
      skip # We've deprecated this for now
      use_capybara_host do
        sign_in!

        visit dashboard_path
        click_on "I’m ready to explore the new Exercism!"
        assert_no_text "Welcome to Exercism V3!"

        visit dashboard_path
        assert_no_text "Welcome to Exercism V3!"
      end
    end
  end
end
