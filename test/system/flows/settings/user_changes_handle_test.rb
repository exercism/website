require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesHandleTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user changes handle" do
        user = create :user, password: "password"

        use_capybara_host do
          sign_in!(user)

          visit settings_path
          form = find("h2", text: "Change your handle").ancestor("form")
          within(form) do
            fill_in "Your handle", with: "newhandle"
            fill_in "Confirm your password", with: "password"
            click_on "Change handle"
          end

          assert_text "Your handle has been changed"
        end
      end

      test "user changes handle with incorrect password" do
        user = create :user, password: "password"

        expecting_errors do
          use_capybara_host do
            sign_in!(user)

            visit settings_path
            form = find("h2", text: "Change your handle").ancestor("form")
            within(form) do
              fill_in "Your handle", with: "newhandle"
              fill_in "Confirm your password", with: "wrongpassword"
              click_on "Change handle"
            end

            assert_text "Incorrect password"
          end
        end
      end
    end
  end
end
