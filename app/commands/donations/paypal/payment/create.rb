# This responds to a new payment that has been made
# and creates a record of it in our database.
class Donations::Paypal::Payment::Create
  include Mandate

  initialize_with :user, :id, :total_in_dollars, subscription: nil

  def call
    Donations::Payment::Create.(user, :paypal, id, amount_in_cents, nil, subscription:)
  end

  private
  def amount_in_cents = (total_in_dollars * 100).to_i
end
