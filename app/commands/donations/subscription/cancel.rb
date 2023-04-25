class Donations::Subscription::Cancel
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :canceled)
    User::InsidersStatus::TriggerUpdate.(subscription.user)
  end
end
