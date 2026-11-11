# Handle a Paypal IPN event with 'txn_type' = 'web_accept'.
# We no longer take one-off donations directly through PayPal
# (donors can use PayPal through Stripe), so we ignore completed
# payments. We still apply amount changes to existing PayPal payments.
class Payments::Paypal::Payment::IPN::HandleWebAccept
  include Mandate

  initialize_with :payload

  def call
    case payment_status
    when "Canceled_Reversal", "Refunded", "Reversed"
      Payments::Paypal::Payment::UpdateAmount.(external_id, amount)
    end
  end

  private
  def amount = payload["mc_gross"].to_f
  def external_id = payload["txn_id"]
  def payment_status = payload["payment_status"]
end
