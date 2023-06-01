require_relative '../../test_base'

class Payments::Stripe::PaymentIntent::CreateForPremiumSubscriptionTest < Payments::TestBase
  [
    [:monthly, Exercism.secrets.stripe_premium_monthly_price_id],
    [:yearly, Exercism.secrets.stripe_premium_yearly_price_id]
  ].each do |(interval, expected_price)|
    test "creates subscription with correct price for #{interval} interval" do
      customer_id = SecureRandom.uuid

      payment_intent = mock
      stripe_subscription = mock_stripe_subscription(nil, nil, payment_intent:)

      Stripe::Subscription.expects(:create).with(
        customer: customer_id,
        items: [{
          price: expected_price
        }],
        payment_behavior: 'default_incomplete',
        expand: ['latest_invoice.payment_intent']
      ).returns(stripe_subscription)

      actual = Payments::Stripe::PaymentIntent::CreateForPremiumSubscription.(customer_id, interval)
      assert_equal payment_intent, actual
    end
  end

  test "creates bugsnag when interval is unknown" do
    customer_id = SecureRandom.uuid
    invalid_interval = :invalid

    Bugsnag.expects(:notify).once

    Payments::Stripe::PaymentIntent::CreateForPremiumSubscription.(customer_id, invalid_interval)
  end
end
