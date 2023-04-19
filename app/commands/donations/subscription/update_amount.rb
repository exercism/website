class Donations::Subscription::UpdateAmount
  include Mandate

  initialize_with :subscription, :amount_in_cents

  def call
    subscription.update!(amount_in_cents:)

    # Update based on whether there is another different active subscription
    User::UpdateActiveDonationSubscription.(subscription.user)
  end
end
