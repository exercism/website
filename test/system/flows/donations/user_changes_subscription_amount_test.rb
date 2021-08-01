require "application_system_test_case"
require_relative "../../../support/capybara_helpers"

module Flows
  module Donations
    class UserChangesSubscriptionAmountTest < ApplicationSystemTestCase
      include CapybaraHelpers

      test "user changes subscription amount" do
        subscription_id = "sub_123"
        item_id = "item_123"
        stub_request(:get, "https://api.stripe.com/v1/subscriptions/#{subscription_id}").
          to_return(status: 200, body: { items: { data: [{ id: item_id }] } }.to_json)
        stub_request(:post, "https://api.stripe.com/v1/subscriptions/#{subscription_id}").
          with(body: {
                 items: [
                   id: item_id,
                   price_data: {
                     unit_amount: 1000,
                     currency: "usd",
                     product: Exercism::STRIPE_RECURRING_PRODUCT_ID,
                     recurring: { interval: "month" }
                   }
                 ],
                 proration_behavior: "none"
               }).
          to_return(status: 200, body: {}.to_json)
        user = create :user, active_donation_subscription: true
        create :donations_subscription, stripe_id: subscription_id, user: user, active: true, amount_in_cents: 500

        use_capybara_host do
          sign_in!(user)
          visit donations_settings_path
          click_on "Change amount"
          fill_in "Change donation amount", with: 10
          assert_text "Thank you for increasing your donation!"
          click_on "Change"

          assert_text "You're currently donating $10.00"
        end
      end
    end
  end
end
