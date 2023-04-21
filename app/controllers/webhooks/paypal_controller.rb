# This controller listens for webhooks from PayPal.
module Webhooks
  class PaypalController < BaseController
    def create
      Webhooks::ProcessPaypalUpdate.(
        params[:event_type],
        request.request_parameters[:resource] # params[:resource] does not work as it is populated by Rails
      )

      head :ok
    end
  end
end
