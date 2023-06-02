class Webhooks::ProcessPaypalIpn
  include Mandate

  class PaypalInvalidIpnError < RuntimeError; end
  class PaypalIpnVerificationError < RuntimeError; end

  initialize_with :payload

  def call
    Webhooks::Paypal::Debug.("[IPN] Payload:\n#{payload}")

    case ipn_verification_status
    when "VERIFIED"
      handle_verified
    when "INVALID"
      handle_invalid
    else
      handle_error
    end
  rescue StandardError => e
    Bugsnag.notify(e)
  end

  private
  memoize
  def ipn_verification_status
    response = RestClient.post(IPN_VERIFICATION_URL, ipn_verification_body)
    response.body
  end

  def handle_verified
    Webhooks::Paypal::Debug.("[IPN] VERIFIED")

    params = Rack::Utils.parse_nested_query(payload)
    case params["txn_type"]
    when "web_accept"
      Payments::Paypal::Payment::IPN::HandleWebAccept.(params)
    when "recurring_payment"
      Payments::Paypal::Subscription::IPN::HandleRecurringPayment.(params)
    when "recurring_payment_expired"
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentExpired.(params)
    when "recurring_payment_failed"
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentFailed.(params)
    when "recurring_payment_profile_cancel"
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCancel.(params)
    when "recurring_payment_profile_created"
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentProfileCreated.(params)
    when "recurring_payment_skipped"
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSkipped.(params)
    when "recurring_payment_suspended"
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspended.(params)
    when "recurring_payment_suspended_due_to_max_failed_payment"
      Payments::Paypal::Subscription::IPN::HandleRecurringPaymentSuspendedDueToMaxFailedPayment.(params)
    end
  end

  def handle_invalid
    Webhooks::Paypal::Debug.("[IPN] INVALID")
    raise PaypalInvalidIpnError
  end

  def handle_error
    Webhooks::Paypal::Debug.("[IPN] ERROR")
    raise PaypalIpnVerificationError
  end

  def ipn_verification_body = "cmd=_notify-validate&#{payload}"

  IPN_VERIFICATION_URL = 'https://ipnpb.paypal.com/cgi-bin/webscr'.freeze
  private_constant :IPN_VERIFICATION_URL
end
