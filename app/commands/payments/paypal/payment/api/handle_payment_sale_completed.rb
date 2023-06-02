# Handle a Paypal API event with 'event_type' = 'PAYMENT.SALE.COMPLETED'
class Payments::Paypal::Payment::API::HandlePaymentSaleCompleted
  include Mandate

  initialize_with :payload

  def call
    # Payments::Paypal::Customer::FindOrUpdate.(payer_id, payer_email, user_email:)

    # Payments::Paypal::Payment::Create.(user, external_id, amount, product)
  end

  # def amount = payload["mc_gross"].to_f
  # def external_id = payload["resource"][""]
  # def payment_status = payload["payment_status"]
  # def payer_id = payload["payer_id"]
  # def payer_email = payload["payer_email"]
  # def user_email = payload["custom"]
  # def product = :donation
end
