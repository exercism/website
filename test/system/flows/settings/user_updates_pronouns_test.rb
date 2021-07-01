require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserUpdatesPronounsTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user updates pronouns" do
        user = create :user

        use_capybara_host do
          sign_in!(user)

          visit settings_path
          fill_in "e.g. They", with: "They"
          fill_in "e.g. them", with: "them"
          fill_in "e.g. their", with: "Their"
          click_on "Save pronouns"

          assert_text "Your pronouns have been updated"
        end
      end
    end
  end
end
