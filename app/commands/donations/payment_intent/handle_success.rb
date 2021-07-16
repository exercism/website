module Donations
  module PaymentIntent
    class HandleSuccess
      include Mandate

      initialize_with :user, :id

      def call
        subscription = Donations::Subscription::Create.(user, subscription_data) if subscription_data
        Donations::Payment::Create.(user, payment_intent, subscription: subscription)
      end

      memoize
      def subscription_data
        return unless payment_intent.invoice

        invoice = Stripe::Invoice.retrieve(payment_intent.invoice)
        return unless invoice.subscription

        Stripe::Subscription.retrieve(invoice.subscription)
      end

      memoize
      def payment_intent
        Stripe::PaymentIntent.retrieve(id)
      end
    end
  end
end
