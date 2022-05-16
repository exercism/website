module Donations
  class Subscription
    class HandleCreated
      include Mandate

      def initialize(subscription_id:, payment_intent_id:)
        @subscription_id = subscription_id
        @payment_intent_id = payment_intent_id
      end

      def call
        # Retrieve the payment intent used to pay the subscription
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

        # Set the default payment method for the subscription
        Stripe::Subscription.update(
          subscription_id,
          default_payment_method: payment_intent.payment_method
        )
      end

      private
      attr_reader :subscription_id, :payment_intent_id
    end
  end
end
