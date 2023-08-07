class Payments::Stripe::PaymentIntent::CreateForPayment
  include Mandate

  initialize_with :customer_id, :amount_in_cents, :for_subscription

  def call
    options = {
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true
      }
    }
    options[:setup_future_usage] = "off_session" if for_subscription.present?

    Stripe::PaymentIntent.create(**options)
  end
end
