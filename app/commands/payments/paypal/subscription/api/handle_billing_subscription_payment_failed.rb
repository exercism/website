# Handle a Paypal API event with 'event_type' = 'BILLING.SUBSCRIPTION.PAYMENT.FAILED'
class Payments::Paypal::Subscription::API::HandleBillingSubscriptionPaymentFailed
  include Mandate

  initialize_with :payload

  def call
    subscription = Payments::Subscription.find_by(external_id:, provider: :paypal)
    return unless subscription

    Payments::Subscription::Overdue.(subscription)
  end

  private
  def external_id = payload["resource"]["id"]
end
