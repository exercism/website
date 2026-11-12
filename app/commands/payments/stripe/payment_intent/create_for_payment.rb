class Payments::Stripe::PaymentIntent::CreateForPayment
  include Mandate

  initialize_with :customer_id, :amount_in_cents, trigger: nil

  def call
    options = {
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd',
      automatic_payment_methods: {
        enabled: true
      }
    }
    options[:metadata] = { trigger: } if trigger

    Stripe::PaymentIntent.create(**options)
  end
end
