require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesCommunicationPrefrencesTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user updates communication preferences" do
        user = create :user
        create :user_communication_preferences, user: user

        use_capybara_host do
          sign_in!(user)

          visit communication_preferences_settings_path
          find('label', text: "Email when a mentor starts mentoring my solution").click
          click_on "Change preferences"

          assert_text "Your preferences have been updated"
        end
      end
    end
  end
end
