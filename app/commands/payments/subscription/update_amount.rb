class Payments::Subscription::UpdateAmount
  include Mandate

  initialize_with :subscription, :amount_in_cents

  def call
    subscription.update!(amount_in_cents:)
    User::InsidersStatus::TriggerUpdate.(subscription.user)
  end
end
