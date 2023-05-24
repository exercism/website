class Payments::Subscription::UpdateStatus
  include Mandate

  initialize_with :subscription, :status

  def call
    subscription.update!(status:)
    User::UpdateActiveDonationSubscription.(subscription.user) if subscription.donation?
    User::Premium::Update.(subscription.user) if subscription.premium?
  end
end
