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
            items: [{
              id: item_id,
              price_data: {
                unit_amount: 1234,
                currency: "usd",
                product: Exercism.secrets.stripe_recurring_product_id,
                recurring: { interval: "month" }
              }
            }]
          }).
          to_return(status: 200, body: {}.to_json)
        user = create :user
        create :payments_subscription, external_id: subscription_id, user:, status: :active, amount_in_cents: 500

        use_capybara_host do
          sign_in!(user)
          visit donations_settings_path
          click_on "Change amount"
          fill_in "Change donation amount", with: "12.34"
          assert_text "Thank you for increasing your donation!"
          click_on "Change"

          assert_text "You're currently donating $12.34"
        end
      end
    end
  end
end
