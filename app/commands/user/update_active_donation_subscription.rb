class User::UpdateActiveDonationSubscription
  include Mandate

  initialize_with :user

  def call
    user.update(active_donation_subscription:)
    User::InsidersStatus::TriggerUpdate.(user)
  end

  private
  def active_donation_subscription = user.donation_subscriptions.active.exists?
end
