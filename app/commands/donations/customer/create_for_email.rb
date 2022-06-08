# This creates a new customer in Stripe for an email address.
# This gets called if the user doesn't exist
module Donations
  module Customer
    class CreateForEmail
      include Mandate

      initialize_with :email

      def call
        existing = Stripe::Customer.list(email:, limit: 1).data.first
        existing ? existing.id : Stripe::Customer.create(email:).id
      end
    end
  end
end
