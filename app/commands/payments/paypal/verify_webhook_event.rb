class Payments::Paypal::InvalidWebhookError < RuntimeError; end
class Payments::Paypal::WebhookVerificationError < RuntimeError; end

class Payments::Paypal::VerifyWebhookEvent
  include Mandate

  initialize_with :payload, :headers

  def call
    case request_webhook_event_verification_status!
    when "SUCCESS"
      Payments::Paypal::Debug.("[WEBHOOK] VERIFIED")
      nil
    when "FAILURE"
      Payments::Paypal::Debug.("[WEBHOOK] INVALID")
      raise Payments::Paypal::InvalidWebhookError
    else
      Payments::Paypal::Debug.("[WEBHOOK] ERROR")
      raise Payments::Paypal::WebhookVerificationError
    end
  end

  private
  def request_webhook_event_verification_status!
    response = RestClient.post(WEBHOOK_VERIFICATION_URL, verification_body)
    json = JSON.parse(response.body, symbolize_names: true)
    json[:verification_status]
  end

  def headers
    {
      authorization:,
      content_type: :json
    }
  end

  def authorization = "Bearer #{access_token}"
  def access_token = Payments::Paypal::RequestAccessToken.()

  def verification_body
    {
      auth_algo: headers['PAYPAL-AUTH-ALGO'],
      cert_url: headers['PAYPAL-CERT-URL'],
      transmission_id: headers['PAYPAL-TRANSMISSION-ID'],
      transmission_sig: headers['PAYPAL-TRANSMISSION-SIG'],
      transmission_time: headers['PAYPAL-TRANSMISSION-TIME'],
      webhook_id: Exercism.secrets.paypal_webhook_id,
      webhook_event: payload
    }
  end

  WEBHOOK_VERIFICATION_URL = "#{Exercism.config.paypal_api_url}/v1/notifications/verify-webhook-signature".freeze
  private_constant :WEBHOOK_VERIFICATION_URL
end
