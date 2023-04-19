# This responds to a new subscription that has been made
# and creates a record of it in our database. The actual
# creation of the subscription within Stripe happens through
# "payment intents".
class Donations::Stripe::Subscription::Create
  include Mandate

  initialize_with :user, :stripe_data

  def call = Donations::Subscription::Create.(user, :stripe, external_id, amount_in_cents)

  private
  def external_id = stripe_data.id
  def amount_in_cents = stripe_data.items.data[0].price.unit_amount
end
