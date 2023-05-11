# Handle a Paypal IPN event with 'txn_type' = 'web_accept'
class Donations::Paypal::Payment::HandleWebAccept
  include Mandate

  initialize_with :payload

  def call
    case payment_status
    when "Completed"
      handle_completed
    end
  end

  private
  def handle_completed
    return unless user

    Donations::Paypal::Payment::Create.(user, transaction_id, amount)
  end

  memoize
  def user = Donations::Paypal::Customer::FindOrUpdate.(payer_id, payer_email)

  def amount = payload["mc_gross"].to_f
  def transaction_id = payload["txn_id"]
  def payment_status = payload["payment_status"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]

  # Canceled_Reversal
  # Completed
  # Declined
  # Expired
  # Failed
  # In-Progress
  # Partially_Refunded
  # Pending
  # Processed
  # Refunded
  # Reversed
  # Voided
end
