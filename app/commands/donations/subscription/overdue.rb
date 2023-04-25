class Donations::Subscription::Overdue
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :overdue)
    User::InsidersStatus::TriggerUpdate.(subscription.user)
  end
end
