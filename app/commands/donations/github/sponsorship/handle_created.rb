# This responds to a Github sponsorship webhook event with
# the action being 'created'
class Donations::Github::Sponsorship::HandleCreated
  include Mandate

  initialize_with :user, :node_id, :privacy_level, :is_one_time, :monthly_price_in_cents

  def call
    subscription = Donations::Github::Subscription::Create.(user, node_id, monthly_price_in_cents) unless is_one_time
    Donations::Github::Payment::Create.(user, node_id, monthly_price_in_cents, subscription:)
  end
end
