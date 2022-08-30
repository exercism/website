require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesUserPrefrencesTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user updates user preferences" do
        user = create :user

        use_capybara_host do
          sign_in!(user)

          visit user_preferences_settings_path
          find('label', text: I18n.t('user_preferences.auto_update_exercises')).click
          click_on "Change preferences"

          assert_text "Your preferences have been updated"
        end
      end
    end
  end
end
