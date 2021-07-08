module Donations
  module Customer
    class Create
      include Mandate

      initialize_with :user

      def call
        user.with_lock do
          unless user.stripe_customer_id
            customer = Stripe::Customer.create(email: user.email)
            user.update_column(:stripe_customer_id, customer.id)
          end
        end

        user.stripe_customer_id
      end
    end
  end
end
