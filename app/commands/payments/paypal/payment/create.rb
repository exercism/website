# This responds to a new payment that has been made
# and creates a record of it in our database.
class Payments::Paypal::Payment::Create
  include Mandate

  initialize_with :user, :id, :amount, subscription: nil

  def call = Payments::Payment::Create.(user, :paypal, id, amount_in_cents, nil, subscription:)

  private
  def amount_in_cents = (amount * 100).to_i
end
