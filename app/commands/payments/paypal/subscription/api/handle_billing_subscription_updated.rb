# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.UPDATED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionUpdated
  include Mandate

  initialize_with :payload

  def call
    # TODO: decide what to do here
  end
end
