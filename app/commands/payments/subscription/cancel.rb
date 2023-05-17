class Payments::Subscription::Cancel
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :canceled)
    User::UpdateActiveDonationSubscription.(subscription.user) if subscription.donation?
    User::Premium::Update.(subscription.user) if subscription.premium?
  end
end
