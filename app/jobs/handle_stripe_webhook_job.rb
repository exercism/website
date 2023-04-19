class HandleStripeWebhookJob < ApplicationJob
  queue_as :default

  def perform(signature, payload_body)
    event = Stripe::Webhook.construct_event(
      payload_body, signature, Exercism.secrets.stripe_endpoint_secret
    )

    case event.type
    when 'payment_intent.succeeded'
      Donations::Stripe::PaymentIntent::HandleSuccess.(payment_intent: event.data.object)
    when 'invoice.payment_failed'
      Donations::Stripe::PaymentIntent::HandleInvoiceFailure.(invoice: event.data.object)
    when 'invoice.payment_succeeded'
      data_object = event.data.object
      if data_object['billing_reason'] == 'subscription_create'
        Donations::Stripe::Subscription::HandleCreated.(
          subscription_id: data_object['subscription'],
          payment_intent_id: data_object['payment_intent']
        )
      end
    end
  end
end
