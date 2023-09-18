require "application_system_test_case"
require_relative "../../../support/capybara_helpers"
require_relative "../../../support/redirect_helpers"

module Flows
  module Settings
    class UserDeletesProfileTest < ApplicationSystemTestCase
      include CapybaraHelpers
      include RedirectHelpers

      test "user deletes profile" do
        user = create :user
        create(:user_profile, user:)

        use_capybara_host do
          sign_in!(user)
          visit settings_path

          click_on "Delete your profile"
          within(".m-generic-confirmation") { click_on "Continue" }

          wait_for_redirect
          assert_no_text "Delete your profile"
        end
      end
    end
  end
end
