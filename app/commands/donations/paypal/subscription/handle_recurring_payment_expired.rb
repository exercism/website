# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_expired'
class Donations::Paypal::Subscription::HandleRecurringPaymentExpired
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    Donations::Subscription::Overdue.(subscription)
  end
end
