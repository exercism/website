# This cancels a payment within Stripe, and updates a record
# within our database.
class Donations::Subscription::Cancel
  include Mandate

  initialize_with :subscription

  def call
    begin
      Stripe::Subscription.cancel(subscription.stripe_id)
    rescue Stripe::InvalidRequestError
      data = Stripe::Subscription.retrieve(subscription.stripe_id)

      # Raise if we failed to cancel an active subscription
      raise if data.status == 'active'
    end

    Donations::Subscription::Deactivate.(subscription)
  end
end
