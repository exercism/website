# This responds to a Github sponsorship webhook event with
# the action being 'cancelled'
class Payments::Github::Sponsorship::HandleCancelled
  include Mandate

  initialize_with :user, :node_id, :is_one_time

  def call
    return if is_one_time

    subscription = user.subscriptions.find_by(external_id: node_id, provider: :github)
    raise unless subscription

    Payments::Subscription::Cancel.(subscription)
  end
end
