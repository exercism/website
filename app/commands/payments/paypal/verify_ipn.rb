class Payments::Paypal::VerifyIPN
  include Mandate

  initialize_with :payload

  def call
    # Development/sandbox IPNs cannot be verified
    return if Rails.env.development?

    case request_ipn_verification_status!
    when "VERIFIED"
      Payments::Paypal::Debug.("[IPN] VERIFIED")
    when "INVALID"
      Payments::Paypal::Debug.("[IPN] INVALID")
      raise Payments::Paypal::InvalidIPNError
    else
      Payments::Paypal::Debug.("[IPN] ERROR")
      raise Payments::Paypal::IPNVerificationError
    end
  end

  private
  def request_ipn_verification_status!
    response = RestClient.post(IPN_VERIFICATION_URL, ipn_verification_body)
    response.body
  rescue StandardError => e
    Payments::Paypal::Debug.("[IPN] ERROR: #{e.message}")
    raise Payments::Paypal::IPNVerificationError
  end

  def ipn_verification_body = "cmd=_notify-validate&#{payload}"

  IPN_VERIFICATION_URL = 'https://ipnpb.paypal.com/cgi-bin/webscr'.freeze
  private_constant :IPN_VERIFICATION_URL
end
