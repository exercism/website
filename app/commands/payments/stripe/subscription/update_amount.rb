# This updates a payment within Stripe, and updates a record
# within our database.
class Payments::Stripe::Subscription::UpdateAmount
  include Mandate

  initialize_with :subscription, :amount_in_cents

  def call
    stripe_data = Stripe::Subscription.retrieve(subscription.external_id)

    Stripe::Subscription.update(
      subscription.external_id,
      items: [{
        id: stripe_data.items.data[0].id,
        price_data: {
          unit_amount: amount_in_cents,
          currency: 'usd',
          product: Exercism.secrets.stripe_recurring_product_id,
          recurring: {
            interval: 'month'
          }
        }
      }]
    )

    Payments::Subscription::UpdateAmount.(subscription, amount_in_cents)
  end
end
