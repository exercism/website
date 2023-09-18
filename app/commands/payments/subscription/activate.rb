class Payments::Subscription::Activate
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :active)
    User::InsidersStatus::UpdateForPayment.(subscription.user)
  end
end
