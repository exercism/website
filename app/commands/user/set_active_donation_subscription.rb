class User::SetActiveDonationSubscription
  include Mandate

  initialize_with :user, :active

  def call
    user.update(active_donation_subscription: active)
    User::InsidersStatus::TriggerUpdate.(user)
  end
end
