require_relative '../test_base'

class Donations::PaymentIntent::CreateForPaymentTest < Donations::TestBase
  test "creates correctly" do
    customer_id = SecureRandom.uuid
    amount_in_dollars = "15" # Check works as a string
    amount_in_cents = 1500

    payment_intent = mock

    Stripe::PaymentIntent.expects(:create).with(
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd'
    ).returns(payment_intent)

    actual = Donations::PaymentIntent::CreateForPayment.(customer_id, amount_in_dollars)
    assert_equal payment_intent, actual
  end
end
