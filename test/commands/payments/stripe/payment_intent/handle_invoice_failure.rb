require_relative '../../test_base'

class Payments::Stripe::PaymentIntent::HandleInvoiceFailureTest < Payments::TestBase
  test "disable user when three or more payment intents have failed in last 24 hours" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    customer = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id, customer:)
    user = create :user, stripe_customer_id: customer, disabled_at: nil, uid: nil

    # Sanity check
    refute user.disabled?

    Stripe::Charge.expects(:search).returns(Array.new(3, {}))

    Payments::Stripe::PaymentIntent::HandleInvoiceFailure.(invoice:)

    assert user.reload.disabled?
  end

  test "don't disable user when less than three payment intents have failed in last 24 hours" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    customer = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id, customer:)
    user = create :user, stripe_customer_id: customer, disabled_at: nil, uid: nil

    # Sanity check
    refute user.disabled?

    Stripe::Charge.expects(:search).returns(Array.new(2, {}))

    Payments::Stripe::PaymentIntent::HandleInvoiceFailure.(invoice:)

    refute user.reload.disabled?
  end

  test "don't disable users that have authenticated via GitHub" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    customer = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id, customer:)
    user = create :user, stripe_customer_id: customer, disabled_at: nil, uid: 'a13gb341'

    # Sanity check
    refute user.disabled?

    Stripe::Charge.expects(:search).never

    Payments::Stripe::PaymentIntent::HandleInvoiceFailure.(invoice:)

    refute user.reload.disabled?
  end

  test "don't disable user when no user found with customer ID" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    customer = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id, customer:)

    Stripe::Charge.expects(:search).never

    Payments::Stripe::PaymentIntent::HandleInvoiceFailure.(invoice:)
  end

  test "raises when invoice doesn't have customer" do
    invoice_id = SecureRandom.uuid
    subscription_id = SecureRandom.uuid
    invoice = mock_stripe_invoice(invoice_id, subscription_id, customer: nil)

    assert_raises do
      Payments::Stripe::PaymentIntent::HandleInvoiceFailure.(invoice:)
    end
  end

  test "raises when id or invoice isn't passed" do
    assert_raises do
      Payments::Stripe::PaymentIntent::HandleInvoiceFailure.()
    end
  end
end
