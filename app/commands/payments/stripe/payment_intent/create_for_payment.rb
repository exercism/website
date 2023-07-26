class Payments::Stripe::PaymentIntent::CreateForPayment
  include Mandate

  initialize_with :customer_id, :amount_in_cents

  def call
    Stripe::PaymentIntent.create(
      customer: customer_id,
      amount: amount_in_cents,
      currency: 'usd',
      setup_future_usage: 'off_session'
    )
  end
end
