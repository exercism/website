# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_suspended_due_to_max_failed_payment'
class Donations::Paypal::Subscription::HandleRecurringPaymentSuspendedDueToMaxFailedPayment
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    Donations::Subscription::Overdue.(subscription)
  end
end
