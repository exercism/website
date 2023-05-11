# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_expired'
class Donations::Paypal::Subscription::HandleRecurringPaymentExpired
  include Mandate

  initialize_with :payload

  def call
    subscription = Donations::Subscription.find_by(external_id:, provider: :paypal)
    return unless subscription

    Donations::Subscription::Cancel.(subscription)
  end

  private
  def external_id = payload["recurring_payment_id"]
end
