class User::UpdateActiveDonationSubscription
  include Mandate

  initialize_with :user

  def call
    user.update!(active_donation_subscription:)
    User::InsidersStatus::TriggerUpdate.(user)
  end

  private
  def active_donation_subscription = user.subscriptions.donation.active.exists?
end
