require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserUpdatesProfileTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user updates profile" do
        user = create :user

        use_capybara_host do
          sign_in!(user)

          visit settings_path

          # https://github.com/redux-form/redux-form/issues/686#issuecomment-437096243
          fill_in "Name", with: "Name", fill_options: { clear: :backspace }
          click_on "Save profile data"

          assert_field "Name", with: "Name"
          assert_text "Your profile has been saved"
        end
      end

      test "user updates social accounts" do
        user = create :user
        create(:user_profile, user:)

        use_capybara_host do
          sign_in!(user)

          visit settings_path
          fill_in "Github", with: "github.com/user"
          fill_in "Twitter", with: "twitter.com/user"
          fill_in "LinkedIn", with: "linkedin.com/user"
          click_on "Save profile data"

          assert_field "Github", with: "github.com/user"
          assert_field "Twitter", with: "twitter.com/user"
          assert_field "LinkedIn", with: "linkedin.com/user"
          assert_text "Your profile has been saved"
        end
      end
    end
  end
end
