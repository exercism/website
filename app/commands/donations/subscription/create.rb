# This responds to a new subscription that has been made
# and creates a record of it in our database. The actual
# creation of the subscription within Stripe happens through
# "payment intents".
class Donations::Subscription::Create
  include Mandate

  initialize_with :user, :provider, :stripe_data

  def call
    Donations::Subscription.create!(
      user:,
      provider:,
      external_id: stripe_data.id,
      amount_in_cents: stripe_data.items.data[0].price.unit_amount,
      status: :active
    ).tap do
      User::SetActiveDonationSubscription.(user, true)
    end
  rescue ActiveRecord::RecordNotUnique
    Donations::Subscription.find_by!(external_id: stripe_data.id, provider:)
  end
end
