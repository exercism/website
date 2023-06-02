# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.CANCELLED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionCancelled
  include Mandate

  initialize_with :payload

  def call; end
end
