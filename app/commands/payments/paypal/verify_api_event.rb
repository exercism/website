class Payments::Paypal::VerifyAPIEvent
  include Mandate

  initialize_with :event, :headers

  def call
    case request_api_event_verification_status!
    when "SUCCESS"
      Payments::Paypal::Debug.("[Webhook] VERIFIED")
    when "FAILURE"
      Payments::Paypal::Debug.("[Webhook] INVALID")
      raise Payments::Paypal::InvalidAPIEventError
    else
      Payments::Paypal::Debug.("[Webhook] ERROR")
      raise Payments::Paypal::APIEventVerificationError
    end
  end

  private
  def request_api_event_verification_status!
    response = RestClient.post(API_EVENT_VERIFICATION_URL, verification_body.to_json, verification_headers)
    json = JSON.parse(response.body, symbolize_names: true)
    json[:verification_status]
  rescue StandardError => e
    Payments::Paypal::Debug.("[Webhook] ERROR: #{e.message}")
    raise Payments::Paypal::APIEventVerificationError
  end

  def verification_headers
    {
      authorization:,
      content_type: :json
    }
  end

  def authorization = "Bearer #{access_token}"
  def access_token = Payments::Paypal::RequestAccessToken.()

  def verification_body
    {
      transmission_id: headers['PAYPAL-TRANSMISSION-ID'],
      transmission_time: headers['PAYPAL-TRANSMISSION-TIME'],
      cert_url: headers['PAYPAL-CERT-URL'],
      auth_algo: headers['PAYPAL-AUTH-ALGO'],
      transmission_sig: headers['PAYPAL-TRANSMISSION-SIG'],
      webhook_id: Exercism.secrets.paypal_webhook_id,
      webhook_event: event
    }
  end

  API_EVENT_VERIFICATION_URL = "#{Exercism.config.paypal_api_url}/v1/notifications/verify-webhook-signature".freeze
  private_constant :API_EVENT_VERIFICATION_URL
end
