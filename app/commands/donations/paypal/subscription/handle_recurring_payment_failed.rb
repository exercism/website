# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_failed'
class Donations::Paypal::Subscription::HandleRecurringPaymentFailed
  include Mandate

  initialize_with :payload

  def call
    subscription = Donations::Subscription.find_by(external_id:, provider: :paypal)
    return unless subscription

    Donations::Subscription::Overdue.(subscription)
  end

  private
  def external_id = payload["recurring_payment_id"]
end
