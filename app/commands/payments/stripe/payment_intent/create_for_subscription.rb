class Payments::Stripe::PaymentIntent::CreateForSubscription
  include Mandate

  initialize_with :customer_id, :amount_in_cents

  def call
    subscription = Stripe::Subscription.create(
      customer: customer_id,
      items: [{
        price_data: {
          unit_amount: amount_in_cents,
          currency: 'usd',
          product: Exercism.secrets.stripe_recurring_product_id,
          recurring: {
            interval: 'month'
          }
        }
      }],
      payment_behavior: 'default_incomplete',
      expand: ['latest_invoice.payment_intent']
    )

    subscription.latest_invoice.payment_intent
  end
end
