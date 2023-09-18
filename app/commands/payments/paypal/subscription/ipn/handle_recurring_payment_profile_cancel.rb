# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_profile_cancel'
class Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCancel
  include Mandate

  initialize_with :payload

  def call
    subscription = Payments::Subscription.find_by(external_id:, provider: :paypal)
    return unless subscription

    Payments::Subscription::Cancel.(subscription)
  end

  private
  def external_id = payload["recurring_payment_id"]
end
