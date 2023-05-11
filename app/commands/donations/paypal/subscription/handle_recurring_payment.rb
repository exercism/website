# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment'
class Donations::Paypal::Subscription::HandleRecurringPayment
  include Mandate

  initialize_with :resource

  def call
    subscription = Donations::Subscription.find_by(external_id: resource[:id], provider: :paypal)
    return unless subscription

    Donations::Subscription::Activate.(subscription)
  end
end
