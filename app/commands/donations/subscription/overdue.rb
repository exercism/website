class Donations::Subscription::Overdue
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :overdue)
    User::UpdateActiveDonationSubscription.(subscription.user)
  end
end
