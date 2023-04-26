class Donations::Subscription::Cancel
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :canceled)
    User::UpdateActiveDonationSubscription.(subscription.user)
  end
end
