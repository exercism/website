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

  test "log error in sentry when email uses blocked domain" do
    block_domain = create :user_block_domain
    email = "#{SecureRandom.uuid}@#{block_domain.domain}"
    type = 'payment'
    amount_in_cents = '1200'

    Stripe::Customer.expects(:create).never
    Stripe::PaymentIntent.expects(:create).never
    Stripe::Subscription.expects(:create).never

    Sentry.expects(:capture_exception).once

    assert_nil Payments::Stripe::PaymentIntent::Create.(email, type, amount_in_cents)
  end

  test "passes a known trigger on and tracks checkout_started" do
    customer_id = SecureRandom.uuid
    user = create :user, stripe_customer_id: customer_id
    payment_intent = mock

    Stripe::Customer.expects(:retrieve).with(customer_id).once
    Payments::Stripe::PaymentIntent::CreateForSubscription.expects(:call).
      with(customer_id, '1200', trigger: "beg_modal").returns(payment_intent)
    Analytics::TrackEvent.expects(:defer).with(
      user,
      "checkout_started",
      properties: {
        trigger: "beg_modal",
        payment_type: "subscription",
        amount_in_cents: 1200,
        currency: "usd",
        interval: "month"
      }
    )

    actual = Payments::Stripe::PaymentIntent::Create.(user, 'subscription', '1200', trigger: "beg_modal")
    assert_equal payment_intent, actual
  end

  test "drops an unknown trigger" do
    customer_id = SecureRandom.uuid
    user = create :user, stripe_customer_id: customer_id

    Stripe::Customer.expects(:retrieve).with(customer_id).once
    Payments::Stripe::PaymentIntent::CreateForPayment.expects(:call).
      with(customer_id, '1600', trigger: nil).returns(mock)
    Analytics::TrackEvent.expects(:defer).with(
      user,
      "checkout_started",
      properties: { payment_type: "payment", amount_in_cents: 1600, currency: "usd" }
    )

    Payments::Stripe::PaymentIntent::Create.(user, 'payment', '1600', trigger: "somewhere")
  end
end
