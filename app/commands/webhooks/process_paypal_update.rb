class Webhooks::ProcessPaypalUpdate
  include Mandate

  initialize_with :event_type, :resource

  def call
    case event_type
    when "BILLING.SUBSCRIPTION.ACTIVATED", "BILLING.SUBSCRIPTION.RE-ACTIVATED"
      Donations::Paypal::Subscription::HandleActivated.(resource)
    when "BILLING.SUBSCRIPTION.CANCELLED", "BILLING.SUBSCRIPTION.EXPIRED"
      Donations::Paypal::Subscription::HandleCancelled.(resource)
    when "BILLING.SUBSCRIPTION.CREATED"
      Donations::Paypal::Subscription::HandleCreated.(resource)
    when "BILLING.SUBSCRIPTION.PAYMENT.FAILED"
      Donations::Paypal::Subscription::HandlePaymentFailed.(resource)
    when "BILLING.SUBSCRIPTION.UPDATED"
      Donations::Paypal::Subscription::HandleUpdated.(resource)
    when "PAYMENT.SALE.COMPLETED"
      Donations::Paypal::Payment::HandleSaleCompleted.(resource)
    when "PAYMENT.SALE.DENIED"
      Donations::Paypal::Payment::HandleSaleDenied.(resource)
    when "PAYMENT.SALE.REFUNDED"
      Donations::Paypal::Payment::HandleSaleRefunded.(resource)
    when "PAYMENT.SALE.REVERSED"
      Donations::Paypal::Payment::HandleSaleReversed.(resource)
    when "PAYMENTS.PAYMENT.CREATED"
      Donations::Paypal::Payment::HandlePaymentCreated.(resource)
    end
  end
end
