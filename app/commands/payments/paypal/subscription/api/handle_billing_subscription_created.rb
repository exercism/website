# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.CREATED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionCreated
  include Mandate

  initialize_with :payload

  def call; end
end
