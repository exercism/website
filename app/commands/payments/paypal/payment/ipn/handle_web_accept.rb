# Handle a Paypal IPN event with 'txn_type' = 'web_accept'
class Payments::Paypal::Payment::IPN::HandleWebAccept
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
  memoize
  def user = Payments::Paypal::Customer::FindOrUpdate.(payer_id, payer_email, user_id:)

  def handle_completed
    return unless user

    Payments::Paypal::Payment::Create.(user, external_id, amount)
  end

  def handle_canceled_reversal = Payments::Paypal::Payment::UpdateAmount.(external_id, amount)
  def handle_refunded = Payments::Paypal::Payment::UpdateAmount.(external_id, amount)
  def handle_reversed = Payments::Paypal::Payment::UpdateAmount.(external_id, amount)

  def amount = payload["mc_gross"].to_f
  def external_id = payload["txn_id"]
  def payment_status = payload["payment_status"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
  def user_id = payload["custom"]
end
