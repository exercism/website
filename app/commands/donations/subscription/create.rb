module Donations
  module Subscription
    class Create
      include Mandate

      def initialize(user, amount_in_dollars, payment_intent_id: nil)
        @user = user
        @amount_in_dollars = amount_in_dollars.to_i
        @payment_intent_id = payment_intent_id
      end

      def call
        payment_intent = obtain_payment_intent!

        OpenStruct.new(
          payment_intent_id: payment_intent.id,
          payment_intent_client_secret: payment_intent.client_secret
        )
      end

      private
      attr_reader :user, :amount_in_dollars, :payment_intent_id

      def obtain_payment_intent!
        return create_subscription! if payment_intent_id.blank?

        update_payment_intent!
        # rescue
        #   create_subscription!
      end

      def update_payment_intent!
        Stripe::PaymentIntent.update(payment_intent_id, amount: amount_in_cents)
      end

      def create_subscription!
        customer_id = Donations::Customer::Create.(user)
        subscription = Stripe::Subscription.create(
          customer: customer_id,
          items: [{
            price_data: {
              unit_amount: amount_in_cents,
              currency: 'usd',
              product: Donations::STRIPE_PRODUCT_ID,
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
        amount_in_dollars * 100
      end
    end
  end
end
