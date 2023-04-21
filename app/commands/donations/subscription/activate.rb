# Activate a subcription within our database.
class Donations::Subscription::Activate
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :active)

    # Update based on whether there is another different active subscription
    User::UpdateActiveDonationSubscription.(subscription.user)
  end
end
