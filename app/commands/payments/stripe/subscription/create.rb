# This responds to a new subscription that has been made
# and creates a record of it in our database. The actual
# creation of the subscription within Stripe happens through
# "payment intents".
class Payments::Stripe::Subscription::Create
  include Mandate

  initialize_with :user, :stripe_data

  def call = Payments::Subscription::Create.(user, :stripe, product, external_id, amount_in_cents)

  private
  def external_id = stripe_data.id
  def price = stripe_data.items.data[0].price
  def amount_in_cents = price.unit_amount
  def product = Payments::Stripe::Product.from_product_id(price.product)
end
