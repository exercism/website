# This updates a subscription within Stripe, and updates a record
# within our database.
class Payments::Stripe::Subscription::UpdatePlan
  include Mandate

  initialize_with :subscription, :interval

  def call
    stripe_data = Stripe::Subscription.retrieve(subscription.external_id)

    Stripe::Subscription.update(
      subscription.external_id,
      items: [{
        id: stripe_data.items.data[0].id,
        price:
      }]
    )

    subscription.update(interval:)
    Payments::Subscription::UpdateAmount.(subscription, amount_in_cents)
  end

  memoize
  def price = Payments::Stripe.price_id_from_interval(interval)
  def amount_in_cents = Payments::Stripe.amount_in_cents_from_price_id(price)
end
