class Payments::Stripe::Subscription::HandleCreated
  include Mandate

  initialize_with subscription_id: Mandate::NO_DEFAULT, payment_intent_id: Mandate::NO_DEFAULT

  def call
    # Retrieve the payment intent used to pay the subscription
    payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

    # Set the default payment method for the subscription
    Stripe::Subscription.update(
      subscription_id,
      default_payment_method: payment_intent.payment_method
    )
  end
end
