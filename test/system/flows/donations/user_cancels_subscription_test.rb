require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Donations
    class UserCancelsSubscriptionTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user cancels subscription" do
        subscription_id = "sub_123"
        stub_request(:delete, "https://api.stripe.com/v1/subscriptions/#{subscription_id}").
          to_return(status: 200, body: {}.to_json)
        user = create :user, active_donation_subscription: true
        create :donations_subscription, stripe_id: subscription_id, user: user, active: true

        use_capybara_host do
          sign_in!(user)
          visit donations_settings_path
          click_on "cancel your recurring donation"
          click_on "Yes - please cancel it."

          assert_no_text "You're currently donating"
        end
      end
    end
  end
end
