module Donations
  class PaymentIntentError < RuntimeError
  end

  module PaymentIntent
    class Create
      include Mandate

      initialize_with :user, :type, :amount_in_dollars

      def call
        customer_id = Donations::Customer::Create.(user)

        case type.to_sym
        when :subscription
          CreateForSubscription.(customer_id, amount_in_dollars)
        else
          CreateForPayment.(customer_id, amount_in_dollars)
        end
      end
    end
  end
end
