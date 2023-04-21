# This cancels a payment within Stripe, and makes a record
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

    subscription.update!(active: false)

    # Update based on whether there is another different active subscription
    user = subscription.user
    User::SetActiveDonationSubscription.(user, user.donation_subscriptions.active.exists?)
  end
end
