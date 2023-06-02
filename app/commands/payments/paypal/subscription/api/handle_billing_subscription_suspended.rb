# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.SUSPENDED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionSuspended
  include Mandate

  initialize_with :payload

  def call; end
end
