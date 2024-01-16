class Payments::Subscription::Overdue
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :overdue)
    User::InsidersStatus::UpdateForPayment.(subscription.user)
  end
end
