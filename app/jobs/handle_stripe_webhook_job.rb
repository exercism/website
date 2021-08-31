class HandleStripeWebhookJob < ApplicationJob
  queue_as :default

  def perform(signature, payload_body)
    event = Stripe::Webhook.construct_event(
      payload_body, signature, Exercism.secrets.stripe_endpoint_secret
    )

    case event.type
    when 'payment_intent.succeeded'
      Donations::PaymentIntent::HandleSuccess.(payment_intent: event.data.object)
    end
  end
end
