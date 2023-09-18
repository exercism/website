# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.EXPIRED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionExpired
  include Mandate

  initialize_with :payload

  def call
    subscription = Payments::Subscription.find_by(external_id:, provider: :paypal)
    return unless subscription

    Payments::Subscription::Cancel.(subscription)
  end

  private
  def external_id = payload["resource"]["id"]
end
