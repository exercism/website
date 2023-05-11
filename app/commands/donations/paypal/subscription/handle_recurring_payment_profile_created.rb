# Handle a Paypal IPN event with 'txn_type' = 'recurring_payment_profile_created'
class Donations::Paypal::Subscription::HandleRecurringPaymentProfileCreated
  include Mandate

  initialize_with :payload

  def call
    user = Donations::Paypal::Customer::FindOrUpdate.(payer_id, payer_email)
    return unless user

    Donations::Paypal::Subscription::Create.(user, external_id, amount)
  end

  def amount = payload["amount"].to_f
  def external_id = payload["recurring_payment_id"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
end
