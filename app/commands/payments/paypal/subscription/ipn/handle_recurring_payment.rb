# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment'
class Payments::Paypal::Subscription::IPN::HandleRecurringPayment
  include Mandate

  initialize_with :payload

  def call
    user = Payments::Paypal::Customer::FindOrUpdate.(payer_id, payer_email, paypal_subscription_id: subscription_external_id)
    return unless user

    subscription = Payments::Subscription.find_by(external_id: subscription_external_id, provider: :paypal)
    return unless subscription

    Payments::Paypal::Payment::Create.(user, payment_external_id, amount, subscription:)
  end

  private
  def amount = payload["mc_gross"].to_f
  def subscription_external_id = payload["recurring_payment_id"]
  def payment_external_id = payload["txn_id"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
  def interval = Payments::Paypal.interval_from_payment_cycle(payload["payment_cycle"])
end
