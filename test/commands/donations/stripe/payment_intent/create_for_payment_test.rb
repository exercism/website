require_relative '../../test_base'

class Donations::Stripe::PaymentIntent::CreateForPaymentTest < Donations::TestBase
  test "creates correctly" do
    customer_id = SecureRandom.uuid
    amount_in_cents = 1500

    payment_intent = mock

    Stripe::PaymentIntent.expects(:create).with(
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd',
      setup_future_usage: 'off_session'
    ).returns(payment_intent)

    actual = Donations::Stripe::PaymentIntent::CreateForPayment.(customer_id, amount_in_cents)
    assert_equal payment_intent, actual
  end
end
