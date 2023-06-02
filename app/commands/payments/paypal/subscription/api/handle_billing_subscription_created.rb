# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.CREATED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionCreated
  include Mandate

  initialize_with :payload

  def call
    # We're ignoring this event as we manually create the subscription and this
    # event doesn't seem to register
  end
end
