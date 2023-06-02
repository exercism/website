# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_profile_created'
class Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated
  include Mandate

  initialize_with :payload

  def call
    user = Payments::Paypal::Customer::FindOrUpdate.(payer_id, payer_email)
    return unless user

    Payments::Paypal::Subscription::Create.(user, external_id, amount, product, interval)
  end

  def amount = payload["amount"].to_f
  def external_id = payload["recurring_payment_id"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
  def product = Payments::Paypal.product_from_name(payload["product_name"])
  def interval = Payments::Paypal.interval_from_payment_cycle(payload["payment_cycle"])
end
