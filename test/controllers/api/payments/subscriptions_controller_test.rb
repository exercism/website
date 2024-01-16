require_relative '../base_test_case'

class API::Payments::SubscriptionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :cancel_api_payments_subscription_path, args: 1, method: :patch
  guard_incorrect_token! :update_amount_api_payments_subscription_path, args: 1, method: :patch
  guard_incorrect_token! :current_api_payments_subscriptions_path

  ##########
  # Cancel #
  ##########
  test "cancel proxies correctly" do
    user = create :user
    subscription = create(:payments_subscription, user:)

    ::Payments::Stripe::Subscription::Cancel.expects(:call).with(subscription)

    setup_user(user)
    patch cancel_api_payments_subscription_path(subscription.id), headers: @headers, as: :json

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
    patch update_amount_api_payments_subscription_path(subscription.id, amount_in_cents:), headers: @headers,
      as: :json
    assert_response :ok
    expected = { subscription: { links: { index: donations_settings_url } } }
    assert_equal(expected.to_json, response.body)
  end

  #####################
  # Current #
  #####################
  test "get current subscription" do
    user = create :user
    create(:payments_subscription, :active, user:, amount_in_cents: 100)
    subscription = create(:payments_subscription, :active, :github, user:, amount_in_cents: 200)
    create(:payments_subscription, :canceled, user:, amount_in_cents: 300)

    setup_user(user)
    get current_api_payments_subscriptions_path, headers: @headers, as: :json

    assert_response :ok

    expected = {
      subscription: {
        provider: subscription.provider,
        interval: subscription.interval,
        amount_in_cents: subscription.amount_in_cents
      }
    }
    assert_equal(expected.to_json, response.body)
  end
end
