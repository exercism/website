# Handle a Paypal API event with 'event_type' = 'PAYMENT.SALE.COMPLETED'
class Payments::Paypal::Payment::API::HandlePaymentSaleCompleted
  include Mandate

  initialize_with :payload

  def call; end
end
