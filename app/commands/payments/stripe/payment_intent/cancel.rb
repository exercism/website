class Payments::Stripe::PaymentIntent::Cancel
  include Mandate

  initialize_with :id

  def call
    if invoice
      void_invoice!
    else
      Stripe::PaymentIntent.cancel(id)
    end
  end

  def void_invoice!
    delete_subscription!(invoice.subscription) if invoice.subscription.present?
    Stripe::Invoice.void_invoice(invoice.id) if invoice.status == "open"
  rescue StandardError => e
    Rails.logger.error(e)
  end

  def delete_subscription!(subscription_id)
    Stripe::Subscription.cancel(subscription_id)
  rescue StandardError => e
    Rails.logger.error(e)
  end

  memoize
  def invoice
    payment_intent = Stripe::PaymentIntent.retrieve(id)
    return nil unless payment_intent.invoice

    Stripe::Invoice.retrieve(payment_intent.invoice)
  end
end
