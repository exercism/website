# Handle a Paypal IPN event with 'txn_type' = 'web_accept'
class Donations::Paypal::Payment::HandleWebAccept
  include Mandate

  initialize_with :payload

  def call
    case payment_status
    when "Completed"
      handle_completed
    when "Canceled_Reversal"
      handle_canceled_reversal
    when "Refunded"
      handle_refunded
    when "Reversed"
      handle_reversed
    end
  end

  private
  def handle_completed
    user = Donations::Paypal::Customer::FindOrUpdate.(payer_id, payer_email)
    return unless user

    Donations::Paypal::Payment::Create.(user, external_id, amount)
  end

  def handle_canceled_reversal
    Donations::Paypal::Payment::UpdateAmount.(external_id, amount)
  end

  def handle_refunded
    Donations::Paypal::Payment::UpdateAmount.(external_id, amount)
  end

  def handle_reversed
    Donations::Paypal::Payment::UpdateAmount.(external_id, amount)
  end

  def amount = payload["mc_gross"].to_f
  def external_id = payload["txn_id"]
  def payment_status = payload["payment_status"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
end
