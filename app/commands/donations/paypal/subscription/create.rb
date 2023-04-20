# This responds to a new subscription that has been made
# and creates a record of it in our database.
class Donations::Paypal::Subscription::Create
  include Mandate

  initialize_with :user, :id, :total_in_dollars

  def call
    Donations::Subscription::Create.(user, :paypal, id, amount_in_cents)
  end

  private
  def amount_in_cents = (total_in_dollars * 100).to_i
end
