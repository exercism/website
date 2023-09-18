require_relative '../../test_base'

class Payments::Stripe::Subscription::HandleCreatedTest < Payments::TestBase
  test "update subscription" do
    subscription_id = SecureRandom.uuid
    payment_intent_id = SecureRandom.uuid
    payment_method = SecureRandom.uuid

    payment_intent_data = mock_stripe_payment_intent(payment_intent_id, payment_method:)
    Stripe::PaymentIntent.expects(:retrieve).with(payment_intent_id).returns(payment_intent_data)
    Stripe::Subscription.expects(:update).with(
      subscription_id,
      default_payment_method: payment_method
    )

    Payments::Stripe::Subscription::HandleCreated.(
      subscription_id:,
      payment_intent_id:
    )
  end
end
