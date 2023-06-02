# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.PAYMENT.FAILED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionPaymentFailed
  include Mandate

  initialize_with :payload

  def call; end
end
