require_relative '../../test_base'

class Payments::Stripe::PaymentIntent::CreateForPaymentTest < Payments::TestBase
  test "creates correctly" do
    customer_id = SecureRandom.uuid
    amount_in_cents = 1500

    payment_intent = mock

    Stripe::PaymentIntent.expects(:create).with(
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true
      }
    ).returns(payment_intent)

    actual = Payments::Stripe::PaymentIntent::CreateForPayment.(customer_id, amount_in_cents)
    assert_equal payment_intent, actual
  end

  test "stores the trigger in the metadata" do
    customer_id = SecureRandom.uuid

    Stripe::PaymentIntent.expects(:create).with do |options|
      options[:metadata] == { trigger: "donations_page" }
    end.returns(mock)

    Payments::Stripe::PaymentIntent::CreateForPayment.(customer_id, 1500, trigger: "donations_page")
  end
end
