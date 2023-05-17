require_relative '../base_test_case'

module API
  class Payments::SubscriptionsControllerTest < API::BaseTestCase
    guard_incorrect_token! :cancel_api_donations_subscription_path, args: 1, method: :patch
    guard_incorrect_token! :update_amount_api_donations_subscription_path, args: 1, method: :patch

    ##########
    # Cancel #
    ##########
    test "cancel proxies correctly" do
      user = create :user
      subscription = create(:payments_subscription, user:)

      ::Payments::Stripe::Subscription::Cancel.expects(:call).with(subscription)

      setup_user(user)
      patch cancel_api_donations_subscription_path(subscription.id), headers: @headers, as: :json

      assert_response :ok
      expected = { subscription: { links: { index: donations_settings_url } } }
      assert_equal(expected.to_json, response.body)
    end

    #################
    # Update Amount #
    #################
    test "update_amount proxies correctly" do
      user = create :user
      subscription = create(:payments_subscription, user:)
      amount_in_cents = '5000'

      ::Payments::Stripe::Subscription::UpdateAmount.expects(:call).with(subscription, amount_in_cents)

      setup_user(user)
      patch update_amount_api_donations_subscription_path(subscription.id, amount_in_cents:), headers: @headers,
        as: :json
      assert_response :ok
      expected = { subscription: { links: { index: donations_settings_url } } }
      assert_equal(expected.to_json, response.body)
    end
  end
end
