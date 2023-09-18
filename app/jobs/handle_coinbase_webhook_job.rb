class HandleCoinbaseWebhookJob < ApplicationJob
  queue_as :default

  def perform(signature, payload_body)
    event = CoinbaseCommerce::Webhook.construct_event(payload_body, signature, Exercism.secrets.coinbase_webhooks_secret)

    case event.type
    when 'charge:resolved'
      Payments::Coinbase::HandleResolvedCharge.(event.data)
    end
  end
end
