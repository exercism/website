# This controller listens for webhooks from PayPal.
module Webhooks
  class PaypalController < BaseController
    def create
      Webhooks::Paypal::VerifySignature.(request.headers, payload_body)

      Webhooks::ProcessPaypalUpdate.(
        params[:event_type],
        request.request_parameters[:resource] # params[:resource] does not work as it is populated by Rails
      )

      head :ok
    rescue Webhooks::Paypal::VerifySignature::SignatureVerificationError => e
      Bugsnag.notify(e)
      head :forbidden
    end
  end
end
