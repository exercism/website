# Deactivate a subcription within our database.
class Donations::Subscription::Deactivate
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :canceled)

    # Update based on whether there is another different active subscription
    User::UpdateActiveDonationSubscription.(subscription.user)
  end
end
