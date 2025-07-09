require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Settings
    class UserResendsConfirmationEmailTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user resends confirmation email" do
        ActionMailer::Base.deliveries.clear
        user = create :user
        create(:user_profile, user:)

        use_capybara_host do
          sign_in!(user)

          visit settings_path
          change_email
          visit settings_path

          click_on "Resend email"

          sleep(0.2)

          assert_text "We've sent a confirmation email to newemail@exercism.org"
        end

        perform_enqueued_jobs
        assert_equal 4, ActionMailer::Base.deliveries.count
        ActionMailer::Base.deliveries.clear
      end

      private
      def change_email
        form = find("h2", text: "Change your email").ancestor("form")
        within(form) do
          fill_in "Your email", with: "newemail@exercism.org"
          fill_in "Confirm your password", with: "password"
          click_on "Change email"
        end

        assert_text "We've sent a confirmation email to newemail@exercism.org"
      end
    end
  end
end
