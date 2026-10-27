class Payments::Stripe::HandleEvent
  include Mandate

  initialize_with :event

  def call
    case event.type
    when 'payment_intent.succeeded'
      Payments::Stripe::PaymentIntent::HandleSuccess.(payment_intent: event.data.object)
    when 'invoice.payment_failed'
      Payments::Stripe::PaymentIntent::HandleInvoiceFailure.(invoice: event.data.object)
    when 'invoice.payment_succeeded'
      data_object = event.data.object
      if data_object['billing_reason'] == 'subscription_create'
        Payments::Stripe::Subscription::HandleCreated.(
          subscription_id: data_object['subscription'],
          payment_intent_id: data_object['payment_intent']
        )

        # The invoice is paid by now, so record the subscription in case
        # it wasn't recorded when the payment intent succeeded.
        Payments::Stripe::PaymentIntent::HandleSuccess.(id: data_object['payment_intent'])
      end
    end
  end
end
