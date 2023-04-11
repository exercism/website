require_relative '../test_base'

class Donations::PaymentIntent::CancelTest < Donations::TestBase
  test "cancels for subscription" do
    payment_intent_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    invoice_id = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id)
    payment_intent = mock_stripe_payment_intent(
      payment_intent_id,
      invoice_id:
    )

    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent)
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:cancel).with(subscription_id)
    Stripe::Invoice.expects(:void_invoice).with(invoice_id)

    Donations::PaymentIntent::Cancel.(payment_intent_id)
  end

  test "does not void unopen invoices" do
    payment_intent_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    invoice_id = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id, status: 'closed')
    payment_intent = mock_stripe_payment_intent(
      payment_intent_id,
      invoice_id:
    )

    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent)
    Stripe::Invoice.expects(:retrieve).with(invoice_id).returns(invoice)
    Stripe::Subscription.expects(:cancel).with(subscription_id)
    Stripe::Invoice.expects(:void_invoice).never

    Donations::PaymentIntent::Cancel.(payment_intent_id)
  end

  test "cancels payments" do
    payment_intent_id = SecureRandom.uuid
    payment_intent = mock_stripe_payment_intent(
      payment_intent_id
    )

    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent)
    Stripe::PaymentIntent.expects(:cancel).with(payment_intent_id)

    Donations::PaymentIntent::Cancel.(payment_intent_id)
  end
end
