# This controller listens for webhooks from stripe.
module Webhooks
  class StripeController < BaseController
    def create
      signature = request.headers['HTTP_STRIPE_SIGNATURE']

      Stripe::Webhook::Signature.verify_header(
        payload_body, signature, Exercism.secrets.stripe_endpont_secret
      )

      HandleStripeWebhookJob.perform_later(signature, payload_body)

      head 200
    rescue JSON::ParserError => e
      Bugsnag.notify(e)
      head 400
    rescue Stripe::SignatureVerificationError => e
      Bugsnag.notify(e)
      head 400
    end
  end
end
