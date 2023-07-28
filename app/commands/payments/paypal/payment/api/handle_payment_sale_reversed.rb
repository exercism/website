# Handle a Paypal API event with 'event_type' = 'PAYMENT.SALE.REVERSED'
class Payments::Paypal::Payment::API::HandlePaymentSaleReversed
  include Mandate

  initialize_with :payload

  def call
    # We're ignoring this event as this event is already processed as
    # the IPN event with 'txn_type' = 'recurring_payment'
  end
end
