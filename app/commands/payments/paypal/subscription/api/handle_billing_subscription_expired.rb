# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.EXPIRED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionExpired
  include Mandate

  initialize_with :payload

  def call; end
end
