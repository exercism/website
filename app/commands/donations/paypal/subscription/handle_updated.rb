# This responds to a Paypal 'BILLING.SUBSCRIPTION.UPDATED' webhook event
class Donations::Paypal::Subscription::HandleUpdated
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    total_in_dollars = resource.dig(:plan, :payment_definitions).first.dig(:amount, :value)
    amount_in_cents = (total_in_dollars * 100).to_i
    Donations::Subscription::UpdateAmount.(subscription, amount_in_cents)
  end
end
