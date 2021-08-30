require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserChangesEmailTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user changes email" do
        user = create :user, password: "password"

        use_capybara_host do
          sign_in!(user)

          visit settings_path
          form = find("h2", text: "Change your email").ancestor("form")
          within(form) do
            fill_in "Your email", with: "newemail@exercism.org"
            fill_in "Confirm your password", with: "password"
            click_on "Change email"
          end

          assert_text "We've sent a confirmation email to newemail@exercism.org"
        end
      end

      test "user changes email with incorrect password" do
        user = create :user, password: "password"

        expecting_errors do
          use_capybara_host do
            sign_in!(user)

            visit settings_path
            form = find("h2", text: "Change your email").ancestor("form")
            within(form) do
              fill_in "Your email", with: "newemail@exercism.org"
              fill_in "Confirm your password", with: "wrongpassword"
              click_on "Change email"
            end

            assert_text "Incorrect password"
          end
        end
      end
    end
  end
end
