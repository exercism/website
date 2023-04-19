class Donations::Subscription::UpdateAmount
  include Mandate

  initialize_with :subscription, :amount_in_cents

  def call
    subscription.update!(amount_in_cents:)
  end
end
