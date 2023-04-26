# This responds to a Github sponsorship webhook event with
# the action being 'tier_changed'
class Donations::Github::Sponsorship::HandleTierChanged
  include Mandate

  initialize_with :user, :node_id, :is_one_time, :monthly_price_in_cents

  def call
    return if is_one_time

    subscription = user.donation_subscriptions.find_by(external_id: node_id, provider: :github)
    raise unless subscription

    Donations::Subscription::UpdateAmount.(subscription, amount_in_cents: monthly_price_in_cents)
  end
end
