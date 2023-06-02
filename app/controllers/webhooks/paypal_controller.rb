# This controller listens for webhooks from PayPal.
class Webhooks::PaypalController < Webhooks::BaseController
  def create
    Webhooks::ProcessPaypalIpnUpdate.defer(payload_body) if payload_body.include?("ipn_track_id")

    head :ok
  end

  private
  def ipn_event? = payload_body.include?("ipn_track_id")
  def api_event? = payload_body.include?("event_type")
end
