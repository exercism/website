class Webhooks::ProcessPaypalWebhookEvent
  include Mandate

  initialize_with :payload, :headers

  def call
    Payments::Paypal::Debug.("[Webhook] Headers:\n#{headers}")
    Payments::Paypal::Debug.("[Webhook] Payload:\n#{payload}")
    Payments::Paypal::VerifyWebhookEvent.(payload, headers)

    handle!
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  private
  def handle!
    # params = Rack::Utils.parse_nested_query(payload)
    # TODO: handle events
    # case params["txn_type"]
    # when "web_accept"
    #   Payments::Paypal::Payment::IPN::HandleWebAccept.(params)
    # when "recurring_payment"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPayment.(params)
    # when "recurring_payment_expired"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpired.(params)
    # when "recurring_payment_failed"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPaymentFailed.(params)
    # when "recurring_payment_profile_cancel"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCancel.(params)
    # when "recurring_payment_profile_created"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated.(params)
    # when "recurring_payment_skipped"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSkipped.(params)
    # when "recurring_payment_suspended"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspended.(params)
    # when "recurring_payment_suspended_due_to_max_failed_payment"
    #   Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspendedDueToMaxFailedPayment.(params)
    # end
  end
end
