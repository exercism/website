class Donations::Subscription::UpdateAmount
  include Mandate

  initialize_with :subscription, :amount_in_cents

  def call
    subscription.update!(amount_in_cents:)

    # Update based on whether there is another different active subscription
    user = subscription.user
    User::SetActiveDonationSubscription.(user, user.donation_subscriptions.active.exists?)
  end
end
