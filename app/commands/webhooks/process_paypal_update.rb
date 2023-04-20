class Webhooks::ProcessPaypalUpdate
  include Mandate

  initialize_with :event_type, :id, :resource

  def call
    case event_type
    when "BILLING.SUBSCRIPTION.ACTIVATED"
      Donations::Paypal::Subscription::HandleActivated.defer(id, resource)
    when "BILLING.SUBSCRIPTION.CANCELLED"
      Donations::Paypal::Subscription::HandleCancelled.defer(id, resource)
    when "BILLING.SUBSCRIPTION.CREATED"
      Donations::Paypal::Subscription::HandleCreated.defer(id, resource)
    when "BILLING.SUBSCRIPTION.EXPIRED"
      Donations::Paypal::Subscription::HandleExpired.defer(id, resource)
    when "BILLING.SUBSCRIPTION.PAYMENT.FAILED"
      Donations::Paypal::Subscription::HandlePaymentFailed.defer(id, resource)
    when "BILLING.SUBSCRIPTION.RE-ACTIVATED"
      Donations::Paypal::Subscription::HandleReActivated.defer(id, resource)
    when "BILLING.SUBSCRIPTION.UPDATED"
      Donations::Paypal::Subscription::HandleUpdated.defer(id, resource)
    when "PAYMENT.SALE.COMPLETED"
      Donations::Paypal::Payment::HandleSaleCompleted.defer(id, resource)
    when "PAYMENT.SALE.DENIED"
      Donations::Paypal::Payment::HandleSaleDenied.defer(id, resource)
    when "PAYMENT.SALE.REFUNDED"
      Donations::Paypal::Payment::HandleSaleRefunded.defer(id, resource)
    when "PAYMENT.SALE.REVERSED"
      Donations::Paypal::Payment::HandleSaleReversed.defer(id, resource)
    when "PAYMENTS.PAYMENT.CREATED"
      Donations::Paypal::Payment::HandlePaymentCreated.defer(id, resource)
    end
  end
end
