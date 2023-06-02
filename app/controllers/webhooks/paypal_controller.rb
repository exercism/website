# This controller listens for webhooks and IPNs from PayPal.
class Webhooks::PaypalController < Webhooks::BaseController
  def create
    Webhooks::ProcessPaypalWebhookEvent.defer(payload_body)
    head :ok
  end

  def ipn
    Webhooks::ProcessPaypalIPN.defer(payload_body)
    head :ok
  end
end
