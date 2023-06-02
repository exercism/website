# Handle a Paypal API event with 'event_type' = 'PAYMENT.SALE.REFUNDED'
class Payments::Paypal::Payment::API::HandlePaymentSaleRefunded
  include Mandate

  initialize_with :payload

  def call; end
end
