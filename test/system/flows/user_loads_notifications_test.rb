require "application_system_test_case"
require_relative "../../support/capybara_helpers"

module Flows
  class UserLoadsNotificationsTest < ApplicationSystemTestCase
    include CapybaraHelpers

    test "user views notifications" do
      user = create :user
      badge = create :rookie_badge
      create :acquired_badge_notification, user: user, params: { badge: badge }

      use_capybara_host do
        sign_in!(user)
        visit notifications_temp_modals_path

        assert_text "You have been awarded the Rookie badge."
      end
    end

    test "user views unrevealed badges" do
      # user = create :user

      # sign_in!(user)
      # visit dashboard_path
      # find(".c-notification").click

      # assert_text "You have been awarded the Rookie badge."
    end
  end
end
