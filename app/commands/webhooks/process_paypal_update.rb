class Webhooks::ProcessPaypalUpdate
  include Mandate

  class PaypalInvalidIpnError < RuntimeError; end
  class PaypalIpnVerificationError < RuntimeError; end

  initialize_with :payload

  def call
    Webhooks::Paypal::Debug.("PAYLOAD: #{payload}")

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
    Webhooks::Paypal::Debug.("VERIFIED")
    # TODO: handle verified

    # params = Rack::Utils.parse_nested_query(payload)
  end

  def handle_invalid
    Webhooks::Paypal::Debug.("INVALID")
    raise PaypalInvalidIpnError
  end

  def handle_error
    Webhooks::Paypal::Debug.("ERROR")
    raise PaypalIpnVerificationError
  end

  def ipn_verification_body = "cmd=_notify-validate&#{payload}"

  IPN_VERIFICATION_URL = 'https://ipnpb.paypal.com/cgi-bin/webscr'.freeze
  private_constant :IPN_VERIFICATION_URL
end
