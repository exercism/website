module Donations
  module Subscription
    class Create
      include Mandate

      initialize_with :user, :amount_in_dollars

      def call
        customer_id = Donations::Customer::Create.(user)

        subscription = Stripe::Subscription.create(
          customer: customer_id,
          items: [{
            price_data: {
              unit_amount: amount_in_dollars * 100,
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

        OpenStruct.new(
          id: subscription.id,
          client_secret: subscription.latest_invoice.payment_intent.client_secret
        )
      end
    end
  end
end
