# This responds to a Github sponsorship webhook event with
# the action being 'created'
class Payments::Github::Sponsorship::HandleCreated
  include Mandate

  queue_as :default

  initialize_with :user, :node_id, :is_one_time, :monthly_price_in_cents

  def call
    subscription = Payments::Github::Subscription::Create.(user, node_id, monthly_price_in_cents) unless is_one_time
    Payments::Github::Payment::Create.(user, node_id, monthly_price_in_cents, subscription:)
  end
end
