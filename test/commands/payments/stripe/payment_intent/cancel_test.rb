require_relative '../../test_base'

class Payments::Stripe::PaymentIntent::CancelTest < Payments::TestBase
  setup do
    @customer_id = SecureRandom.uuid
    @user = create :user, stripe_customer_id: @customer_id
  end

  test "cancels for subscription" do
    payment_intent_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    invoice_id = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id)
    payment_intent = mock_stripe_payment_intent(
      payment_intent_id,
      invoice_id:,
      customer: @customer_id
    )

    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent)
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:cancel).with(subscription_id)
    Stripe::Invoice.expects(:void_invoice).with(invoice_id)

    Payments::Stripe::PaymentIntent::Cancel.(@user, payment_intent_id)
  end

  test "does not void unopen invoices" do
    payment_intent_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    invoice_id = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id, status: 'closed')
    payment_intent = mock_stripe_payment_intent(
      payment_intent_id,
      invoice_id:,
      customer: @customer_id
    )

    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent)
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:cancel).with(subscription_id)
    Stripe::Invoice.expects(:void_invoice).never

    Payments::Stripe::PaymentIntent::Cancel.(@user, payment_intent_id)
  end

  test "cancels payments" do
    payment_intent_id = SecureRandom.uuid
    payment_intent = mock_stripe_payment_intent(
      payment_intent_id,
      customer: @customer_id
    )

    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent)
    Stripe::PaymentIntent.expects(:cancel).with(payment_intent_id)

    Payments::Stripe::PaymentIntent::Cancel.(@user, payment_intent_id)
  end

  test "does nothing for another customer's payment intent" do
    payment_intent_id = SecureRandom.uuid
    payment_intent = mock_stripe_payment_intent(
      payment_intent_id,
      invoice_id: SecureRandom.uuid,
      customer: SecureRandom.uuid
    )

    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent)
    Stripe::Invoice.expects(:retrieve).never
    Stripe::Subscription.expects(:cancel).never
    Stripe::Invoice.expects(:void_invoice).never
    Stripe::PaymentIntent.expects(:cancel).never

    Payments::Stripe::PaymentIntent::Cancel.(@user, payment_intent_id)
  end

  test "does nothing if the user has no stripe customer" do
    user = create :user
    payment_intent_id = SecureRandom.uuid

    Stripe::PaymentIntent.expects(:retrieve).never
    Stripe::PaymentIntent.expects(:cancel).never

    Payments::Stripe::PaymentIntent::Cancel.(user, payment_intent_id)
  end
end
