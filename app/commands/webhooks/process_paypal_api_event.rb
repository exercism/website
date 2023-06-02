class Webhooks::ProcessPaypalAPIEvent
  include Mandate

  initialize_with :payload, :headers

  def call
    Payments::Paypal::Debug.("[Webhook] Headers:\n#{headers}")
    Payments::Paypal::Debug.("[Webhook] Payload:\n#{payload}")
    Payments::Paypal::VerifyAPIEvent.(payload, headers)

    handle!
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  private
  def handle!
    params = Rack::Utils.parse_nested_query(payload)
    case params["event_type"]
    when "PAYMENT.SALE.COMPLETED"
      Payments::Paypal::Payment::API::HandlePaymentSaleCompleted.(params)
    when "PAYMENT.SALE.REFUNDED"
      Payments::Paypal::Payment::API::HandlePaymentSaleRefunded.(params)
    when "PAYMENT.SALE.REVERSED"
      Payments::Paypal::Payment::API::HandlePaymentSaleReversed.(params)
    when "BILLING.SUBSCRIPTION.ACTIVATED"
      Payments::Paypal::Subscription::HandleBillingSubscriptionActivated.(params)
    when "BILLING.SUBSCRIPTION.CANCELLED"
      Payments::Paypal::Subscription::HandleBillingSubscriptionCancelled.(params)
    when "BILLING.SUBSCRIPTION.EXPIRED"
      Payments::Paypal::Subscription::HandleBillingSubscriptionExpired.(params)
    when "BILLING.SUBSCRIPTION.CREATED"
      Payments::Paypal::Subscription::HandleBillingSubscriptionCreated.(params)
    when "BILLING.SUBSCRIPTION.UPDATED"
      Payments::Paypal::Subscription::HandleBillingSubscriptionUpdated.(params)
    when "BILLING.SUBSCRIPTION.SUSPENDED"
      Payments::Paypal::Subscription::HandleBillingSubscriptionSuspended.(params)
    when "BILLING.SUBSCRIPTION.PAYMENT.FAILED"
      Payments::Paypal::Subscription::HandleBillingSubscriptionPaymentFailed.(params)
    end
  end
end
