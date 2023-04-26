require 'uri'
require 'net/http'

class Webhooks::Paypal::VerifySignature
  class SignatureVerificationError < RuntimeError; end

  include Mandate

  initialize_with :headers, :body

  def call
    headers = { 'Content-Type': 'application/json', 'Authorization': "Bearer #{access_token}" }
    response = Net::HTTP.post(WEBHOOK_URI, request_body.to_json, headers)

    raise SignatureVerificationError unless response.is_a?(Net::HTTPSuccess)

    response_body = JSON.parse(response.body, symbolize_names: true)
    raise SignatureVerificationError unless response_body[:verification_status] == 'SUCCESS'
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
