# This controller listens for webhooks and IPNs from PayPal.
class Webhooks::PaypalController < Webhooks::BaseController
  def create
    Webhooks::ProcessPaypalAPIEvent.defer(payload_body, webhook_headers)
    head :ok
  end

  def ipn
    Webhooks::ProcessPaypalIPN.defer(payload_body)
    head :ok
  end

  private
  def webhook_headers = WEBHOOK_HEADER_NAMES.index_with { |key| request.headers[key] }

  WEBHOOK_HEADER_NAMES = %w[PAYPAL-AUTH-ALGO PAYPAL-CERT-URL PAYPAL-TRANSMISSION-ID PAYPAL-TRANSMISSION-SIG
                            PAYPAL-TRANSMISSION-TIME].freeze
  private_constant :WEBHOOK_HEADER_NAMES
end
