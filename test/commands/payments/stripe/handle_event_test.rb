require_relative '../test_base'

class Payments::Stripe::HandleEventTest < Payments::TestBase
  test "handles a succeeded payment intent" do
    payment_intent = OpenStruct.new(id: SecureRandom.uuid)
    event = OpenStruct.new(type: 'payment_intent.succeeded', data: OpenStruct.new(object: payment_intent))

    Payments::Stripe::PaymentIntent::HandleSuccess.expects(:call).with(payment_intent:)

    Payments::Stripe::HandleEvent.(event)
  end

  test "handles the first invoice of a subscription being paid" do
    subscription_id = SecureRandom.uuid
    payment_intent_id = SecureRandom.uuid
    invoice = {
      'billing_reason' => 'subscription_create',
      'subscription' => subscription_id,
      'payment_intent' => payment_intent_id
    }
    event = OpenStruct.new(type: 'invoice.payment_succeeded', data: OpenStruct.new(object: invoice))

    Payments::Stripe::Subscription::HandleCreated.expects(:call).with(subscription_id:, payment_intent_id:)
    Payments::Stripe::PaymentIntent::HandleSuccess.expects(:call).with(id: payment_intent_id)

    Payments::Stripe::HandleEvent.(event)
  end

  test "ignores later subscription invoices" do
    invoice = {
      'billing_reason' => 'subscription_cycle',
      'subscription' => SecureRandom.uuid,
      'payment_intent' => SecureRandom.uuid
    }
    event = OpenStruct.new(type: 'invoice.payment_succeeded', data: OpenStruct.new(object: invoice))

    Payments::Stripe::Subscription::HandleCreated.expects(:call).never
    Payments::Stripe::PaymentIntent::HandleSuccess.expects(:call).never

    Payments::Stripe::HandleEvent.(event)
  end
end
