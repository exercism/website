require_relative '../base_test_case'

class API::Payments::SubscriptionsControllerTest < API::BaseTestCase
  guard_incorrect_token! :cancel_api_payments_subscription_path, args: 1, method: :patch
  guard_incorrect_token! :update_amount_api_payments_subscription_path, args: 1, method: :patch
  guard_incorrect_token! :create_paypal_premium_api_payments_subscriptions_path, method: :post

  ##########
  # Cancel #
  ##########
  test "cancel proxies correctly for donation subscription" do
    user = create :user
    subscription = create(:payments_subscription, :donation, user:)

    ::Payments::Stripe::Subscription::Cancel.expects(:call).with(subscription)

    setup_user(user)
    patch cancel_api_payments_subscription_path(subscription.id), headers: @headers, as: :json

    assert_response :ok
    expected = { subscription: { links: { index: donations_settings_url } } }
    assert_equal(expected.to_json, response.body)
  end

  test "cancel proxies correctly for premium subscription" do
    user = create :user
    subscription = create(:payments_subscription, :premium, user:)

    ::Payments::Stripe::Subscription::Cancel.expects(:call).with(subscription)

    setup_user(user)
    patch cancel_api_payments_subscription_path(subscription.id), headers: @headers, as: :json

    assert_response :ok
    expected = { subscription: { links: { index: premium_settings_url } } }
    assert_equal(expected.to_json, response.body)
  end

  #################
  # Update Amount #
  #################
  test "update_amount proxies correctly" do
    user = create :user
    subscription = create(:payments_subscription, :donation, user:)
    amount_in_cents = '5000'

    ::Payments::Stripe::Subscription::UpdateAmount.expects(:call).with(subscription, amount_in_cents)

    setup_user(user)
    patch update_amount_api_payments_subscription_path(subscription.id, amount_in_cents:), headers: @headers,
      as: :json
    assert_response :ok
    expected = { subscription: { links: { index: donations_settings_url } } }
    assert_equal(expected.to_json, response.body)
  end

  test "update_amount errors when subscription is premium subscription" do
    user = create :user
    subscription = create(:payments_subscription, :premium, user:)
    amount_in_cents = '5000'

    ::Payments::Stripe::Subscription::UpdateAmount.expects(:call).never

    setup_user(user)
    patch update_amount_api_payments_subscription_path(subscription.id, amount_in_cents:), headers: @headers, as: :json
    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "no_donation_subscription",
          "message" => "The subscription is not a donation subscription"
        }
      },
      JSON.parse(response.body)
    )
  end

  #################
  # Update Plan #
  #################
  test "update_plan proxies correctly" do
    user = create :user
    subscription = create(:payments_subscription, :premium, user:)
    interval = :year

    ::Payments::Stripe::Subscription::UpdatePlan.expects(:call).with(subscription, interval)

    setup_user(user)
    patch update_plan_api_payments_subscription_path(subscription.id, interval:), headers: @headers, as: :json
    assert_response :ok
    expected = { subscription: { links: { index: premium_settings_url } } }
    assert_equal(expected.to_json, response.body)
  end

  test "update_plan errors when subscription is premium subscription" do
    user = create :user
    subscription = create(:payments_subscription, :donation, user:)
    interval = :year

    ::Payments::Stripe::Subscription::UpdatePlan.expects(:call).never

    setup_user(user)
    patch update_plan_api_payments_subscription_path(subscription.id, interval:), headers: @headers, as: :json
    assert_response :forbidden
    assert_equal(
      {
        "error" => {
          "type" => "no_premium_subscription",
          "message" => "The subscription is not a premium subscription"
        }
      },
      JSON.parse(response.body)
    )
  end

  ###############################################
  # Create PayPal Exercism Premium Subscription #
  ###############################################
  test "create_paypal_premium returns approval link" do
    user = create :user
    interval = 'month'
    approval_link = "https://www.sandbox.paypal.com/webapps/billing/subscriptions?ba_token=#{SecureRandom.compact_uuid}"

    api_response = {
      status: "APPROVAL_PENDING",
      id: SecureRandom.compact_uuid,
      links: [{ href: approval_link, rel: "approve", method: "GET" }]
    }

    ::Payments::Paypal::Subscription::CreateForPremium.expects(:call).with(user, interval).returns(api_response)

    setup_user(user)
    post create_paypal_premium_api_payments_subscriptions_path(interval:), headers: @headers, as: :json
    assert_response :ok
    expected = { subscription: { links: { approve: approval_link } } }
    assert_equal(expected.to_json, response.body)
  end
end
