require_relative '../../test_base'

class Payments::Stripe::PaymentIntent::CreateTest < Payments::TestBase
  test "creates payment correctly" do
    customer_id = SecureRandom.uuid
    user = create :user, stripe_customer_id: customer_id
    type = 'payment'
    amount_in_cents = '1200'
    payment_intent = mock

    Stripe::Customer.expects(:retrieve).with(customer_id).once
    Stripe::PaymentIntent.expects(:create).with(
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true
      }
    ).returns(payment_intent)

    actual = Payments::Stripe::PaymentIntent::Create.(user, type, amount_in_cents)
    assert_equal payment_intent, actual
  end

  test "creates subscription correctly" do
    customer_id = SecureRandom.uuid
    user = create :user, stripe_customer_id: customer_id
    type = 'subscription'
    amount_in_cents = '1200'
    payment_intent = mock
    stripe_subscription = mock_stripe_subscription(nil, nil, payment_intent:)

    Stripe::Customer.expects(:retrieve).with(customer_id).once
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

    actual = Payments::Stripe::PaymentIntent::Create.(user, type, amount_in_cents)
    assert_equal payment_intent, actual
  end

  test "don't create Stripe payment intent when user's email uses blocked domain" do
    customer_id = SecureRandom.uuid
    block_domain = create :user_block_domain
    user = create :user, stripe_customer_id: customer_id, email: "#{SecureRandom.uuid}@#{block_domain.domain}"
    type = 'payment'
    amount_in_cents = '1200'

    Stripe::Customer.expects(:create).never
    Stripe::PaymentIntent.expects(:create).never
    Stripe::Subscription.expects(:create).never

    assert_nil Payments::Stripe::PaymentIntent::Create.(user, type, amount_in_cents)
  end

  test "don't create Stripe payment intent when email uses blocked domain" do
    block_domain = create :user_block_domain
    email = "#{SecureRandom.uuid}@#{block_domain.domain}"
    type = 'payment'
    amount_in_cents = '1200'

    Stripe::Customer.expects(:create).never
    Stripe::PaymentIntent.expects(:create).never
    Stripe::Subscription.expects(:create).never

    assert_nil Payments::Stripe::PaymentIntent::Create.(email, type, amount_in_cents)
  end

  test "log error in bugsnag when email uses blocked domain" do
    block_domain = create :user_block_domain
    email = "#{SecureRandom.uuid}@#{block_domain.domain}"
    type = 'payment'
    amount_in_cents = '1200'

    Stripe::Customer.expects(:create).never
    Stripe::PaymentIntent.expects(:create).never
    Stripe::Subscription.expects(:create).never

    Bugsnag.expects(:notify).once

    assert_nil Payments::Stripe::PaymentIntent::Create.(email, type, amount_in_cents)
  end
end
