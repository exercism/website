require 'uri'
require 'net/http'

class Webhooks::Paypal::VerifySignature
  class SignatureVerificationError < RuntimeError; end

  include Mandate

  initialize_with :headers, :body

  def call
    headers = { 'Content-Type': 'application/json', 'Authorization': "Bearer #{access_token}" }
    Webhooks::Paypal::Debug.(
      <<~MESSAGE
        [Webhooks::Paypal::VerifySignature-1]
          Headers: #{headers.to_json}
          Body: #{body.to_json}
          Request body: #{request_body.to_json}
          Authorization header: #{headers['Authorization']}
      MESSAGE
    )
    response = Net::HTTP.post(WEBHOOK_URI, request_body.to_json, headers)

    unless response.is_a?(Net::HTTPSuccess)
      Webhooks::Paypal::Debug.(
      <<~MESSAGE
        [Webhooks::Paypal::VerifySignature-2]
          Invalid response: #{response.to_json}
      MESSAGE
    )
      raise SignatureVerificationError
    end

    response_body = JSON.parse(response.body, symbolize_names: true)
    unless response_body[:verification_status] == 'SUCCESS'
      Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::Paypal::VerifySignature-3]
            Not successful: #{response_body.to_json}
        MESSAGE
      )
      raise SignatureVerificationError
    end

    Webhooks::Paypal::Debug.(
        <<~MESSAGE
          [Webhooks::Paypal::VerifySignature-4]
            Successful
        MESSAGE
      )
  rescue StandardError
    raise SignatureVerificationError
  end

  private
  def access_token = Webhooks::Paypal::RequestAccessToken.()

  def request_body
    {
      auth_algo: headers['PAYPAL-AUTH-ALGO'],
      cert_url: headers['PAYPAL-CERT-URL'],
      transmission_id: headers['PAYPAL-TRANSMISSION-ID'],
      transmission_sig: headers['PAYPAL-TRANSMISSION-SIG'],
      transmission_time: headers['PAYPAL-TRANSMISSION-TIME'],
      webhook_id: Exercism.secrets.paypal_webhook_id,
      webhook_event: body
    }
  end

  WEBHOOK_URI = URI('https://api-m.paypal.com/v1/notifications/verify-webhook-signature').freeze
  private_constant :WEBHOOK_URI
end
