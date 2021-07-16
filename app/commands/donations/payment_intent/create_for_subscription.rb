module Donations
  module PaymentIntent
    class CreateForSubscription
      include Mandate

      initialize_with :customer_id, :amount_in_dollars

      def call
        subscription = Stripe::Subscription.create(
          customer: customer_id,
          items: [{
            price_data: {
              unit_amount: amount_in_cents,
              currency: 'usd',
              product: Donations::STRIPE_RECURRING_PRODUCT_ID,
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

      def amount_in_cents
        amount_in_dollars.to_i * 100
      end
    end
  end
end
