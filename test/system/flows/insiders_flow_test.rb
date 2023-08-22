require "application_system_test_case"
require_relative "../../support/capybara_helpers"
require_relative "../../support/websockets_helpers"

module Flows
  class CompleteTutorialTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "someone can donate to join" do
      user = create :user
      user.update(insiders_status: :ineligible)

      use_capybara_host do
        sign_in!(user)

        visit insiders_url

        assert_text "Set up a recurring monthly donation of $10 or more to access Insiders"
      end
    end

    test "someone can join insiders correctly" do
      user = create :user, :staff
      user.update(insiders_status: :eligible)

      use_capybara_host do
        sign_in!(user)

        visit insiders_url

        assert_text "You're currently eligible for Insiders"
        click_on "Get access to Insiders"
        sleep(1)
        assert_text "Welcome to Insiders!"
      end
    end

    test "someone can join lifetime insiders correctly" do
      user = create :user, :staff
      user.update(insiders_status: :eligible_lifetime)

      use_capybara_host do
        sign_in!(user)

        visit insiders_url

        assert_text "We've given you lifetime access to Insiders"
        click_on "Get access to Insiders"
        sleep(1)
        assert_text "Welcome to Insiders!"
      end
    end
  end
end
