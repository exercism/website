class Payments::Subscription::Activate
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :active)
    User::UpdateActiveDonationSubscription.(subscription.user)
  end
end
