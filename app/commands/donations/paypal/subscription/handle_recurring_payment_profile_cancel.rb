# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_profile_cancel'
class Donations::Paypal::Subscription::HandleRecurringPaymentProfileCancel
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    Donations::Subscription::Cancel.(subscription)
  end
end
