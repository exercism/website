# This responds to a new subscription that has been made
# and creates a record of it in our database.
class Payments::Github::Subscription::Create
  include Mandate

  initialize_with :user, :node_id, :amount_in_cents

  def call
    Payments::Subscription::Create.(user, :github, :month, node_id, amount_in_cents)
  end
end
