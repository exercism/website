# This controller listens for webhooks from PayPal.
class Webhooks::PaypalController < Webhooks::BaseController
  def create
    Webhooks::ProcessPaypalUpdate.defer(payload_body)
    head :ok
  end
end
