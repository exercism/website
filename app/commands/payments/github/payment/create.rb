# This responds to a new payment that has been made
# and creates a record of it in our database.
class Payments::Github::Payment::Create
  include Mandate

  initialize_with :user, :node_id, :amount_in_cents, subscription: nil

  def call
    Payments::Payment::Create.(user, :github, node_id, amount_in_cents, nil, subscription:)
  end
end
