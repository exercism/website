require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesThemePrefrencesTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "premium user updates theme preferences" do
        user = create :user, premium_until: Time.current + 2.days

        use_capybara_host do
          sign_in!(user)
          visit user_preferences_settings_path
          find("#dark-theme").click
          assert page.has_css?('body.theme-dark')
          find("#system-theme").click
          assert page.has_css?('body.theme-system')
          find("#sepia-theme").click
          assert page.has_css?('body.theme-sepia')
          find("#light-theme").click
          assert page.has_css?('body.theme-light')

          find("button.toggle-button").click
          assert page.has_css?('body.theme-dark')
        end
      end

      test "non-premium user updates theme preferences" do
        user = create :user

        use_capybara_host do
          sign_in!(user)
          visit user_preferences_settings_path

          assert page.has_css?('button.toggle-button[disabled]')

          find("#sepia-theme").click
          assert page.has_css?('body.theme-sepia')
          find("#light-theme").click
          assert page.has_css?('body.theme-light')

          assert page.has_css?('button#dark-theme[disabled]')
          assert page.has_no_css?('body.theme-dark')

          assert page.has_css?('button#system-theme[disabled]')
          assert page.has_no_css?('body.theme-system')
        end
      end
    end
  end
end
