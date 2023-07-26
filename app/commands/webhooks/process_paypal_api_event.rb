class Webhooks::ProcessPaypalAPIEvent
  include Mandate

  initialize_with :payload, :headers

  def call
    Payments::Paypal::Debug.("")
    Payments::Paypal::Debug.("[Webhook] Headers:\n#{headers}")
    Payments::Paypal::Debug.("[Webhook] Payload:\n#{payload}")
    Payments::Paypal::VerifyAPIEvent.(event, headers)

    handle!
  rescue StandardError => e
    Payments::Paypal::Debug.("[Webhook] Error:\n#{e.message}")
    Bugsnag.notify(e)
  end

  private
  memoize
  def event = JSON.parse(payload)

  def handle!
    Payments::Paypal::Debug.("[Webhook] Parsed:\n#{event}")
    case event["event_type"]
    when "PAYMENT.SALE.COMPLETED"
      Payments::Paypal::Payment::API::HandlePaymentSaleCompleted.(event)
    when "PAYMENT.SALE.REFUNDED"
      Payments::Paypal::Payment::API::HandlePaymentSaleRefunded.(event)
    when "PAYMENT.SALE.REVERSED"
      Payments::Paypal::Payment::API::HandlePaymentSaleReversed.(event)
    when "BILLING.SUBSCRIPTION.ACTIVATED"
      Payments::Paypal::Subscription::API::HandleBillingSubscriptionActivated.(event)
    when "BILLING.SUBSCRIPTION.CANCELLED"
      Payments::Paypal::Subscription::API::HandleBillingSubscriptionCancelled.(event)
    when "BILLING.SUBSCRIPTION.EXPIRED"
      Payments::Paypal::Subscription::API::HandleBillingSubscriptionExpired.(event)
    when "BILLING.SUBSCRIPTION.CREATED"
      Payments::Paypal::Subscription::API::HandleBillingSubscriptionCreated.(event)
    when "BILLING.SUBSCRIPTION.UPDATED"
      Payments::Paypal::Subscription::API::HandleBillingSubscriptionUpdated.(event)
    when "BILLING.SUBSCRIPTION.SUSPENDED"
      Payments::Paypal::Subscription::API::HandleBillingSubscriptionSuspended.(event)
    when "BILLING.SUBSCRIPTION.PAYMENT.FAILED"
      Payments::Paypal::Subscription::API::HandleBillingSubscriptionPaymentFailed.(event)
    end
  end
end
