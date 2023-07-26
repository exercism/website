# This creates a new customer in Stripe and stores
# the id in our database.
class Payments::Stripe::Customer::CreateForUser
  include Mandate

  initialize_with :user

  def call
    user.data.with_lock do
      if user.stripe_customer_id
        begin
          Stripe::Customer.retrieve(user.stripe_customer_id)
        rescue Stripe::InvalidRequestError
          # If for some reason the stripe customer_id isn't valid
          # then nil it and we'll reset it below.
          user.update!(stripe_customer_id: nil)
        end
      end

      unless user.stripe_customer_id
        customer = Stripe::Customer.create(
          email: user.email,
          metadata: { user_id: user.id }
        )
        user.update!(stripe_customer_id: customer.id)
      end
    end

    user.stripe_customer_id
  end
end
