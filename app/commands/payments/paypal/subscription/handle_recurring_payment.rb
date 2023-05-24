# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment'
class Payments::Paypal::Subscription::HandleRecurringPayment
  include Mandate

  initialize_with :payload

  def call
    user = Payments::Paypal::Customer::FindOrUpdate.(payer_id, payer_email)
    return unless user

    subscription = Payments::Subscription.find_by(external_id: subscription_external_id, provider: :paypal)
    return unless subscription

    Payments::Paypal::Payment::Create.(user, payment_external_id, amount, product, subscription:)
  end

  private
  def amount = payload["mc_gross"].to_f
  def subscription_external_id = payload["recurring_payment_id"]
  def payment_external_id = payload["txn_id"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
  def product = Payments::Paypal::Product.from_name(payload["product_name"])
end
