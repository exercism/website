# This responds to a new subscription that has been made
# and creates a record of it in our database.
class Donations::Github::Subscription::Create
  include Mandate

  initialize_with :user, :node_id, :amount_in_cents

  def call
    Donations::Subscription::Create.(user, :github, node_id, amount_in_cents)
  end
end
