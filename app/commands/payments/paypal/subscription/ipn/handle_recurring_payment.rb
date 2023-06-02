# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment'
class Payments::Paypal::Subscription::IPN::HandleRecurringPayment
  include Mandate

  initialize_with :payload

  def call
    user = Payments::Paypal::Customer::FindOrUpdate.(payer_id, payer_email)
    return unless user

    subscription = Payments::Paypal::Subscription::Create.(user, subscription_external_id, amount, product, interval)
    return unless subscription

    Payments::Paypal::Payment::Create.(user, payment_external_id, amount, product, subscription:)
  end

  private
  def amount = payload["mc_gross"].to_f
  def subscription_external_id = payload["recurring_payment_id"]
  def payment_external_id = payload["txn_id"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
  def product = Payments::Paypal.product_from_name(payload["product_name"])
  def interval = Payments::Paypal.interval_from_payment_cycle(payload["payment_cycle"])
end
