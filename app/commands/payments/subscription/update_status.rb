class Payments::Subscription::UpdateStatus
  include Mandate

  initialize_with :subscription, :status

  def call
    subscription.update!(status:)

    if subscription.donation?
      User::UpdateActiveDonationSubscription.(subscription.user)
    elsif subscription.premium?
      User::Premium::Update.(subscription.user)
    end
  end
end
