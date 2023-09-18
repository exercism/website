require_relative '../../test_base'

class Payments::Stripe::PaymentIntent::CreateForSubscriptionTest < Payments::TestBase
  test "creates correctly" do
    customer_id = SecureRandom.uuid
    amount_in_cents = 1500

    payment_intent = mock
    stripe_subscription = mock_stripe_subscription(nil, nil, payment_intent:)

    Stripe::Subscription.expects(:create).with(
      customer: customer_id,
      items: [{
        price_data: {
          unit_amount: amount_in_cents,
          currency: 'usd',
          product: Exercism.secrets.stripe_recurring_product_id,
          recurring: {
            interval: 'month'
          }
        }
      }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent']
    ).returns(stripe_subscription)

    actual = Payments::Stripe::PaymentIntent::CreateForSubscription.(customer_id, amount_in_cents)
    assert_equal payment_intent, actual
  end
end
