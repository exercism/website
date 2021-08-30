module Donations
  class PaymentIntentError < RuntimeError
  end

  module PaymentIntent
    class Create
      include Mandate

      initialize_with :user_or_email, :type, :amount_in_cents

      def call
        customer_id = user ?
          Donations::Customer::CreateForUser.(user) :
          Donations::Customer::CreateForEmail.(user_or_email)

        case type.to_sym
        when :subscription
          CreateForSubscription.(customer_id, amount_in_cents)
        else
          CreateForPayment.(customer_id, amount_in_cents)
        end
      end

      memoize
      def user
        return user_or_email if user_or_email.is_a?(User)

        User.find_by(email: user_or_email)
      end
    end
  end
end
