# This updates a subscription within Stripe, and updates a record
# within our database.
class Payments::Stripe::Subscription::UpdatePlan
  include Mandate

  initialize_with :subscription, :interval

  def call
    return if subscription.interval == interval

    stripe_data = Stripe::Subscription.retrieve(subscription.external_id)

    Stripe::Subscription.update(
      subscription.external_id,
      items: [{
        id: stripe_data.items.data[0].id,
        price: Payments::Stripe::Price.price_id_from_interval(interval)
      }],
      proration_behavior: 'none'
    )

    Payments::Subscription::UpdateAmount.(subscription, amount_in_cents)
  end

  def amount_in_cents = Payments::Stripe::Price.amount_in_cents_from_interval(interval)
end
