require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserResetsApiTokenTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user resets api token" do
        user = create :user
        create(:user_auth_token, user:)

        use_capybara_host do
          sign_in!(user)

          visit api_cli_settings_path

          click_on "Reset token"
          assert_text "Your token has been reset"
        end
      end
    end
  end
end
