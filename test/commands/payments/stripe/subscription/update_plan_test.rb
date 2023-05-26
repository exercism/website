require_relative '../../test_base'

class Payments::Stripe::Subscription::CancelTest < Payments::TestBase
  test "updates amount in stripe" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, user:, external_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)

    Stripe::Subscription.expects(:update).with(
      subscription.external_id,
      items: [{
        id: subscription_data.items.data[0].id,
        price: Exercism.secrets.stripe_premium_yearly_price_id
      }],
      proration_behavior: 'none'
    )

    Payments::Stripe::Subscription::UpdatePlan.(subscription, :year)
  end

  test "updates subscription amount" do
    subscription_id = SecureRandom.uuid
    user = create :user, active_donation_subscription: true
    subscription = create :payments_subscription, user:, external_id: subscription_id

    subscription_data = mock_stripe_subscription(subscription_id, 1000)
    Stripe::Subscription.expects(:retrieve).with(subscription_id).returns(subscription_data)
    Stripe::Subscription.stubs(:update)

    Payments::Stripe::Subscription::UpdatePlan.(subscription, :year)

    assert_equal Payments::Stripe::Price::YEAR_AMOUNT_IN_CENTS, subscription.amount_in_cents
  end
end
