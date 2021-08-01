module Donations
  module PaymentIntent
    class CreateForPayment
      include Mandate

      initialize_with :customer_id, :amount_in_dollars

      def call
        Stripe::PaymentIntent.create(
          customer: customer_id,
          amount: amount_in_cents,
          currency: 'usd'
        )
      end

      def amount_in_cents
        amount_in_dollars.to_i * 100
      end
    end
  end
end
