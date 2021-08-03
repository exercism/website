module Donations
  module PaymentIntent
    class CreateForPayment
      include Mandate

      initialize_with :customer_id, :amount_in_cents

      def call
        Stripe::PaymentIntent.create(
          customer: customer_id,
          amount: amount_in_cents,
          currency: 'usd'
        )
      end
    end
  end
end
