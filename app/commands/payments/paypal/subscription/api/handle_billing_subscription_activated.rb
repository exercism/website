# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.ACTIVATED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionActivated
  include Mandate

  initialize_with :payload

  def call; end
end
