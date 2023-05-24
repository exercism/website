# Handle a Paypal IPN event with 'txn_type' = 'web_accept'
class Payments::Paypal::Payment::HandleWebAccept
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
    return unless user

    Payments::Paypal::Payment::Create.(user, external_id, amount, product, subscription:)
  end

  memoize
  def user = Payments::Paypal::Customer::FindOrUpdate.(payer_id, payer_email)

  memoize
  def subscription
    return nil unless product == :premium

    Payments::Paypal::Subscription::Create.(user, external_id, amount, product)
  end

  def handle_canceled_reversal
    Payments::Paypal::Payment::UpdateAmount.(external_id, amount)
  end

  def handle_refunded
    Payments::Paypal::Payment::UpdateAmount.(external_id, amount)
  end

  def handle_reversed
    Payments::Paypal::Payment::UpdateAmount.(external_id, amount)
  end

  def amount = payload["mc_gross"].to_f
  def external_id = payload["txn_id"]
  def payment_status = payload["payment_status"]
  def payer_id = payload["payer_id"]
  def payer_email = payload["payer_email"]
  def product = Payments::Paypal::Product.from_name(payload["item_name"])
end
