class HandleStripeWebhookJob < ApplicationJob
  queue_as :default

  def perform(signature, payload_body)
    event = Stripe::Webhook.construct_event(
      payload_body, signature, Exercism.secrets.stripe_endpoint_secret,
      tolerance: TOLERANCE
    )

    Payments::Stripe::HandleEvent.(event)
  end

  TOLERANCE = 1.day.to_i
  private_constant :TOLERANCE
end
