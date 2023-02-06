# This controller listens for webhooks from coinbase.
module Webhooks
  class CoinbaseController < BaseController
    def create
      signature = request.headers['HTTP_X_CC_WEBHOOK_SIGNATURE']

      # Validate it works
      CoinbaseCommerce::Webhook.construct_event(payload_body, signature, Exercism.secrets.coinbase_webhooks_secret)

      # Handle it later
      HandleCoinbaseWebhookJob.perform_later(signature, payload_body)

      head :ok
    rescue JSON::ParserError => e
      Bugsnag.notify(e)
      head :bad_request
    rescue CoinbaseCommerce::Errors::SignatureVerificationError => e
      Bugsnag.notify(e)
      head :bad_request
    rescue CoinbaseCommerce::Errors::WebhookInvalidPayload => e
      Bugsnag.notify(e)
      head :bad_request
    end
  end
end
