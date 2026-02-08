# This controller listens for webhooks from stripe.
module Webhooks
  class StripeController < BaseController
    def create
      signature = request.headers['HTTP_STRIPE_SIGNATURE']

      Stripe::Webhook::Signature.verify_header(
        payload_body, signature, Exercism.secrets.stripe_endpoint_secret
      )

      HandleStripeWebhookJob.perform_later(signature, payload_body)

      head :ok
    rescue JSON::ParserError => e
      Sentry.capture_exception(e)
      head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Sentry.capture_exception(e)
      head :bad_request
    end
  end
end
