class Payments::Subscription::Cancel
  include Mandate

  initialize_with :subscription

  def call
    subscription.update!(status: :canceled)
    User::InsidersStatus::Update.defer(subscription.user)
  end
end
