class Payments::Stripe::PaymentIntent::CreateForPayment
  include Mandate

  initialize_with :customer_id, :amount_in_cents

  def call
    options = {
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true
      }
    }

    Stripe::PaymentIntent.create(**options)
  end
end
