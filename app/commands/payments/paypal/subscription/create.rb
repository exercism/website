# This responds to a new subscription that has been made
# and creates a record of it in our database.
class Payments::Paypal::Subscription::Create
  include Mandate

  initialize_with :user, :id, :amount, :product, :interval, status: :active

  def call = Payments::Subscription::Create.(user, :paypal, product, interval, id, amount_in_cents, status:)

  private
  def amount_in_cents = (amount * 100).to_i
end
