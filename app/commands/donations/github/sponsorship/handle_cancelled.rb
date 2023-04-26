# This responds to a Github sponsorship webhook event with
# the action being 'cancelled'
class Donations::Github::Sponsorship::HandleCancelled
  include Mandate

  initialize_with :user, :node_id, :is_one_time

  def call
    return if is_one_time

    subscription = user.donation_subscriptions.find_by(external_id: node_id, provider: :github)
    raise unless subscription

    Donations::Subscription::Deactivate.(subscription)
  end
end
