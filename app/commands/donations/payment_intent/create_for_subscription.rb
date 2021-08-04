module Donations
  module PaymentIntent
    class CreateForSubscription
      include Mandate

      initialize_with :customer_id, :amount_in_cents

      def call
        subscription = Stripe::Subscription.create(
          customer: customer_id,
          items: [{
            price_data: {
              unit_amount: amount_in_cents,
              currency: 'usd',
              product: Exercism::STRIPE_RECURRING_PRODUCT_ID,
              recurring: {
                interval: 'month'
              }
            }
          }],
          payment_behavior: 'default_incomplete',
          expand: ['latest_invoice.payment_intent']
        )

        subscription.latest_invoice.payment_intent
      end
    end
  end
end
